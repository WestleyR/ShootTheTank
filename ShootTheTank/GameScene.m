//
//  GameScene.m
//  ShootTheTank
//
//  Created by Westley Rose on 2/6/21.
//

#import "GameScene.h"

@implementation GameScene {
    SKShapeNode* background;
    SKShapeNode* tank;
    SKShapeNode* otherTank;
}

NSMutableArray <SKShapeNode*>* objects;
NSMutableArray <SKShapeNode*>* bullets;
NSArray <SKTexture*>* fireFrames;

int maxObjectCount = 40;
int currentObjects = 0;

NSURL* multiPlayerDir = NULL;
NSURL* multiPlayerMyFile = NULL;

dispatch_queue_t arrayQueue;

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here

    // Setup the tmp dir
    NSURL *furl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"foobar"]];
    [[NSFileManager defaultManager] createDirectoryAtURL:furl withIntermediateDirectories:YES attributes:nil error:nil];
    multiPlayerDir = furl;
    multiPlayerMyFile = [multiPlayerDir URLByAppendingPathComponent:@"tank"];

    [[NSFileManager defaultManager] createFileAtPath:multiPlayerMyFile.path contents:nil attributes:nil];

    NSLog(@"My tank posistion file: %@", multiPlayerMyFile);

    [self startHosting];

    // Load the fire frames
    NSMutableArray* frames = [NSMutableArray new];
    for (int i = 1; i <= 3; i++) {
        NSString *texture = [NSString stringWithFormat:@"fire_%d", i];
        NSURL* imageURL = [NSBundle.mainBundle URLForResource:texture withExtension:@"png"];
        NSImage* img = [[NSImage alloc] initWithContentsOfURL:imageURL];
        SKTexture* tx = [SKTexture textureWithImage:img];
        [frames addObject:tx];
    }
    fireFrames = frames;

    arrayQueue = dispatch_queue_create("com.west.arrayThread", NULL);

    dispatch_async(arrayQueue, ^{
        objects = [NSMutableArray new];
        bullets = [NSMutableArray new];
    });

    background = (SKShapeNode *)[self childNodeWithName:@"//battleBackground"];
    tank = (SKShapeNode *)[self childNodeWithName:@"//tank"];

    // The background demon to move the map
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            // Spawn objects
            dispatch_async(arrayQueue, ^{
                if (currentObjects < maxObjectCount) {
                    // Spawn somthing

                    //                dispatch_async(arrayQueue, ^{
                    SKShapeNode* obj = [[SKShapeNode alloc] init];

                    CGSize objSize = CGSizeMake([self ranNumFrom:80 to:250], [self ranNumFrom:80 to:250]);

                    obj = [SKShapeNode shapeNodeWithRectOfSize:objSize];

                    SKTexture* tx = [SKTexture textureWithImage:[self getRandomeObjectImage]];
                    [obj setFillTexture:tx];
                    [obj setFillColor:[NSColor whiteColor]];
                    obj.lineWidth = 0;

                    CGPoint objPos = [self ranPoint];
                    obj.position = objPos;

                    [self->background addChild:obj];
                    [objects addObject:obj];
                    //                });
                    currentObjects++;
                }

                // Move the tank
                float speed = tankMovmentSpeed;

                if ((movingUp + movingDown + movingLeft + movingRight) >= 2) {
                    speed /= 1.25;
                }

                if (movingUp) {
                    CGPoint newPos = self->background.position;
                    newPos.y -= speed;
                    [self->background setPosition:newPos];
                }
                if (movingDown) {
                    CGPoint newPos = self->background.position;
                    newPos.y += speed;
                    [self->background setPosition:newPos];
                }
                if (movingLeft) {
                    CGPoint newPos = self->background.position;
                    newPos.x += speed;
                    [self->background setPosition:newPos];
                }
                if (movingRight) {
                    CGPoint newPos = self->background.position;
                    newPos.x -= speed;
                    [self->background setPosition:newPos];
                }

                // Now set the tank rotation

                int angle = (180 / M_PI * self->tank.zRotation);
                if (movingUp) {
                    angle = 0;
                    if (movingLeft) {
                        angle = 45;
                    } else if (movingRight) {
                        angle = 325;
                    }
                } else if (movingDown) {
                    angle = 180;
                    if (movingLeft) {
                        angle = 145;
                    } else if (movingRight) {
                        angle = 245;
                    }
                } else if (movingLeft) {
                    angle = 90;
                } else if (movingRight) {
                    angle = 270;
                }
                double rad = (angle * M_PI / 180);
                [self->tank setZRotation:rad];


                // Now check if the tank colided with another object

                for (SKShapeNode* o in [objects copy]) {
                    if (o == nil) break;

                    int crashRange = 70;

                    int x = o.position.x;
                    int y = o.position.y;

                    int tx = self->background.position.x;
                    int ty = self->background.position.y;

                    if (x < 0) {
                        x = abs(x);
                    } else {
                        x = -abs(x);
                    }
                    if (y < 0) {
                        y = abs(y);
                    } else {
                        y = -abs(y);
                    }

                    //NSLog(@"TANK: %d->%d", tx, ty);
                    //NSLog(@"OBJ: %d->%d", x, y);

                    int xprox = abs(tx - x);
                    int yprox = abs(ty - y);

                    //NSLog(@"TANK PROX: %d->%d", xprox, yprox);
                    if (xprox <= crashRange && yprox <= crashRange) {
                        NSLog(@"CRASH");

                        //dispatch_async(arrayQueue, ^{
                        [o removeFromParent];
                        [objects removeObject:o];
                        //});
                        currentObjects--;
                    }

                    // Now check if any bullet hit an object
                    for (SKShapeNode* b in [bullets copy]) {
                        if (b == nil) break;

                        int crashRange = 40;

                        int x = o.position.x;
                        int y = o.position.y;

                        int bx = b.position.x;
                        int by = b.position.y;

                        int xprox = abs(bx - x);
                        int yprox = abs(by - y);

                        if (xprox <= crashRange && yprox <= crashRange) {
                            NSLog(@"CRASH");

                            //dispatch_async(arrayQueue, ^{
                                [o removeFromParent];
                                [objects removeObject:o];
                                [bullets removeObject:b];
                                [b removeFromParent];
                                currentObjects--;
                            //});

                            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
                                __block SKShapeNode* fire;
                                dispatch_async(arrayQueue, ^{
                                    fire = [[SKShapeNode alloc] init];
                                    CGSize objSize = CGSizeMake([self ranNumFrom:250 to:550], [self ranNumFrom:250 to:550]);
                                    fire = [SKShapeNode shapeNodeWithRectOfSize:objSize];
                                    fire.position = o.position;
                                    [self->background addChild:fire];
                                });

                                for (int f = 0; f < 30; f++) {
                                    for (int i = 0; i < fireFrames.count; ++i) {
                                        //dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        dispatch_async(arrayQueue, ^{
                                            [fire setFillTexture:fireFrames[i]];
                                            [fire setFillColor:[NSColor whiteColor]];
                                            fire.lineWidth = 0;
                                        });
                                        [NSThread sleepForTimeInterval:0.1];
                                    }
                                }
                                // TODO: Need to modify all arrays on one thread, maybe the main thread or another (FIXED. Use arrayQueue!)
                                //dispatch_async(dispatch_get_main_queue(), ^(void) {
                                dispatch_async(arrayQueue, ^{
                                    [fire removeFromParent];
                                });
                            });
                        }
                    }
                }

                // Now save this player posistion
                NSDictionary* tankPosDict = [self getTankPosistion];
                [tankPosDict writeToURL:multiPlayerMyFile atomically:YES];

                [self getAndPlaceOtherTanks];

            });

            [NSThread sleepForTimeInterval:0.01f];
        }
    });
}

NSString* otherPlayerIPAddress = nil;

+ (void)setOtherPlayerIPAddress:(NSString*)ip {
    otherPlayerIPAddress = ip;
}

SKShapeNode* otherTankBullet = nil;

- (int)getAndPlaceOtherTanks {
    if (otherPlayerIPAddress == nil) {
        return 1;
    }

    NSString* url = [NSString stringWithFormat:@"http://%@/tank", otherPlayerIPAddress];
    NSDictionary* otherTankDict = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:url]];

    //NSLog(@"DOO: %@", otherTankDict);

    CGPoint pos;
    pos.x = [otherTankDict[@"tankPosX"] doubleValue];
    pos.y = [otherTankDict[@"tankPosY"] doubleValue];

    if (otherTank == nil) {
        otherTank = [[SKShapeNode alloc] init];
        CGSize objSize = CGSizeMake(128, 128);
        otherTank = [SKShapeNode shapeNodeWithRectOfSize:objSize];

        NSURL* imageURL = [NSBundle.mainBundle URLForResource:@"tank" withExtension:@"png"];
        NSImage* img = [[NSImage alloc] initWithContentsOfURL:imageURL];
        SKTexture* tx = [SKTexture textureWithImage:img];

        [otherTank setFillTexture:tx];
        [otherTank setFillColor:[NSColor redColor]];
        otherTank.lineWidth = 0;
        [self->background addChild:otherTank];
    }
    otherTank.position = pos;

    // Now get the bullets from the other tank

    for (int i = 0; i < [otherTankDict[@"bullets"] count]; i++) {
        CGFloat x = [otherTankDict[@"bullets"][i] doubleValue];
        i++;
        CGFloat y = [otherTankDict[@"bullets"][i] doubleValue];

        //NSLog(@"B: %f->%f", x, y);

        CGPoint pos;
        pos.x = x;
        pos.y = y;

        dispatch_async(arrayQueue, ^{
            if (otherTankBullet == nil) {
                otherTankBullet = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(10, 10) cornerRadius:30 * 0.3];
                otherTankBullet = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(10, 10) cornerRadius:30 * 0.3];
                otherTankBullet.lineWidth = 15;
                otherTankBullet.strokeColor = [NSColor redColor];
                [otherTankBullet runAction:[SKAction sequence:@[
                    [SKAction waitForDuration:2.5],
                    [SKAction fadeOutWithDuration:0.1],
                    [SKAction removeFromParent]]]
                                completion:^{
                    dispatch_async(arrayQueue, ^{
                        [otherTankBullet removeFromParent];
                        otherTankBullet = nil;
                    });

                }];
                dispatch_async(arrayQueue, ^{
                    [self->background addChild:otherTankBullet];
                });
            }
            otherTankBullet.position = pos;

            // Now check if the bullet hit this tank

            int crashRange = 70;

            int tx = self->background.position.x;
            int ty = self->background.position.y;

            double bx, by;

            if (x < 0) {
                bx = fabs(x);
            } else {
                bx = -fabs(x);
            }
            if (y < 0) {
                by = fabs(y);
            } else {
                by = -fabs(y);
            }

            int xprox = fabs(tx - bx);
            int yprox = fabs(ty - by);

            //NSLog(@"TANK PROX: %d->%d", xprox, yprox);
            if (xprox <= crashRange && yprox <= crashRange) {
                NSLog(@"YOUR TANK GOT HIT!!!");
                [self->tank removeFromParent];
            }

        });
    }

    return 0;
}

// isMasterGame determends if the current game is the "master" game.
// The master game sends all objects, while the "slave" game only sends
// the tank location, and its projectiles.
bool isMasterGame = NO;

+ (void)setIsMasterGame:(BOOL)master {
    isMasterGame = master;
}

- (NSDictionary*)getTankPosistion {
    NSMutableDictionary* dict = [NSMutableDictionary new];

    // Get the tank posistion
    double x = background.position.x;
    double y = background.position.y;
    if (x < 0) {
        x = fabs(x);
    } else {
        x = -fabs(x);
    }
    if (y < 0) {
        y = fabs(y);
    } else {
        y = -fabs(y);
    }

    [dict setValue:@(x) forKey:@"tankPosX"];
    [dict setValue:@(y) forKey:@"tankPosY"];

    // Now get the tank projectiles
    NSMutableArray* bulls = [NSMutableArray new];
    int i = 0;
    for (SKShapeNode* b in bullets) {
        [bulls addObject:@(b.position.x)];
        [bulls addObject:@(b.position.y)];
        //[bulls setValue:@(b.position.x) forKey:[NSString stringWithFormat:@"%d_x", i]];
        //[bulls setValue:@(b.position.y) forKey:[NSString stringWithFormat:@"%d_y", i]];
        i++;
    }
//    [dict setValue:bulls forKey:@"bullets"];
    [dict setObject:bulls forKey:@"bullets"];

    return [dict copy];
}

- (NSImage*)getRandomeObjectImage {
    NSArray* images = @[@"obj1", @"tree", @"bush", @"bushytree", @"deadTree"];

    int ranIndex = [self ranNumFrom:0 to:(int)images.count-1];

    NSURL* imageURL = [NSBundle.mainBundle URLForResource:images[ranIndex] withExtension:@"png"];
    return [[NSImage alloc] initWithContentsOfURL:imageURL];
}

- (int)ranNumFrom:(int)min to:(int)max {
    return min + arc4random_uniform((uint32_t)(max - min + 1));
}

- (NSPoint)ranPoint {
    NSPoint p;
    p.x = [self ranNumFrom:-2000 to:2000]; // half of the battle ground res
    p.y = [self ranNumFrom:-2000 to:2000];

    return p;
}

- (void)shootBullet:(CGPoint)pos {
    dispatch_async(arrayQueue, ^{
        CGPoint startPos = self->background.position;
    if (startPos.x < 0) {
        startPos.x = fabs(startPos.x);
    } else {
        startPos.x = -fabs(startPos.x);
    }
    if (startPos.y < 0) {
        startPos.y = fabs(startPos.y);
    } else {
        startPos.y = -fabs(startPos.y);
    }

    SKShapeNode* bullet = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(10, 10) cornerRadius:30 * 0.3];
    bullet.lineWidth = 15;
    bullet.strokeColor = [NSColor blackColor];

    [bullet runAction:[SKAction repeatActionForever:[SKAction moveByX:pos.x y:pos.y duration:0.5]]];
    [bullet runAction:[SKAction sequence:@[
        [SKAction waitForDuration:2.5],
        [SKAction fadeOutWithDuration:0.1],
        [SKAction removeFromParent]]]
           completion:^{
        dispatch_async(arrayQueue, ^{
            [bullets removeObject:bullet];
        });
    }];

    bullet.position = startPos;

//    dispatch_async(arrayQueue, ^{
        [self->background addChild:bullet];
        [bullets addObject:bullet];
    });
}

bool movingUp;
bool movingDown;
bool movingLeft;
bool movingRight;
double tankMovmentSpeed = 5.12;

- (void)keyDown:(NSEvent*)event {
    switch (event.keyCode) {
        case 0x0D: // up
            movingUp = YES;
            break;

        case 0x01: // down
            movingDown = YES;
            break;

        case 0x02: // right
            movingRight = YES;
            break;

        case 0x00: // left
            movingLeft = YES;
            break;

        default:
            NSLog(@"keyDown:'%@' keyCode: 0x%02X", event.characters, event.keyCode);
            break;
    }

}

- (void)keyUp:(NSEvent*)event {
    switch (event.keyCode) {
        case 0x0D: // up
            movingUp = NO;
            break;

        case 0x01: // down
            movingDown = NO;
            break;

        case 0x02: // right
            movingRight = NO;
            break;

        case 0x00: // left
            movingLeft = NO;
            break;

        default:
            NSLog(@"keyDown:'%@' keyCode: 0x%02X", event.characters, event.keyCode);
            break;
    }
}

- (void)startHosting {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSString* cmdPath = [[NSBundle.mainBundle URLForResource:@"gohost" withExtension:@""] path];
        NSLog(@"CMDURL: %@", cmdPath);

        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;

        NSTask* hostingTask = [[NSTask alloc] init];
        hostingTask.launchPath = cmdPath;
        hostingTask.arguments = @[@"-d", multiPlayerDir.path, @"-p", @"80"];
        hostingTask.standardOutput = pipe;

        [hostingTask launch];

        // AppDelegate will kill this prossess when the app terminates
        [AppDelegate setHostingTask:hostingTask];

        NSData *data = [file readDataToEndOfFile];
        [file closeFile];
        NSString *cmdOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"cmd (%d) returned: %@", hostingTask.processIdentifier, cmdOutput);
    });
}

NSTimer* autoShootTimer;
NSPoint mouseDownPos;

- (void)startFireing {
    autoShootTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer *timer) {
        //[SoundFX SFXShootTank];
        [self shootBullet:mouseDownPos];
    }];
}

- (void)stopFireing {
    [autoShootTimer invalidate];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self touchDownAtPoint:[theEvent locationInNode:self]];

    mouseDownPos = [theEvent locationInNode:self];
    [self startFireing];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    //    [self touchMovedToPoint:[theEvent locationInNode:self]];
    //    [self startFireing:[theEvent locationInNode:self]];
    mouseDownPos = [theEvent locationInNode:self];
    //    [self shootBullet:[theEvent locationInNode:self]];
}

- (void)mouseUp:(NSEvent *)theEvent {
    // [self touchUpAtPoint:[theEvent locationInNode:self]];

    [self stopFireing];
}

- (void)touchDownAtPoint:(CGPoint)pos {
    //[SoundFX SFXShootTank];
    [self shootBullet:pos];
}

- (void)touchMovedToPoint:(CGPoint)pos {
    //    SKShapeNode *n = [_spinnyNode copy];
    //    n.position = pos;
    //    n.strokeColor = [SKColor blueColor];
    //    [self addChild:n];
}

- (void)touchUpAtPoint:(CGPoint)pos {
    //    SKShapeNode *n = [_spinnyNode copy];
    //    n.position = pos;
    //    n.strokeColor = [SKColor redColor];
    //    [self addChild:n];
}

- (void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
