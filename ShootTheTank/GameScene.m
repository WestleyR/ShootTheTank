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

//****************
// Changable stuff
//****************

// Starting hit points
NSInteger tankHitPoints = 200;

// The tank moving speed
double tankMovmentSpeed = 15.12;

// The amount of damage that this tank will deal to other tanks
float bulletDamage = 20;


//**************
// Internal vars
//**************

NSMutableArray <SKShapeNode*>* objects;
NSMutableArray <SKShapeNode*>* bullets;
NSArray <SKTexture*>* fireFrames;

NSArray <SKTexture*>* tankRotationTX;

SKLabelNode* tankHealthLabel = nil;
NSString* tankClass = nil;

int maxObjectCount = 40;
int currentObjects = 0;

NSURL* multiPlayerDir = NULL;
NSURL* multiPlayerMyFile = NULL;

dispatch_queue_t arrayQueue;

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here

    // Tank class must be set!
    if (tankClass == nil) {
        NSLog(@"%s tank class must be set!", __func__);
        return;
    }

    // Load the tank roation textures
    NSURL* imageURL = [NSBundle.mainBundle URLForResource:tankClass withExtension:@"png"];
    NSImage* img = [[NSImage alloc] initWithContentsOfURL:imageURL];

    NSMutableArray* tmpArr = [NSMutableArray new];
    int rots[] = {0, 325, 270, 245, 180, 145, 90, 45};
    for (int i = 0; i < 8; i++) {
        NSImage* txImg = [self rotateImage:img toDegrees:rots[i]];
        SKTexture* tx = [SKTexture textureWithImage:txImg];
        [tmpArr addObject:tx];
    }
    tankRotationTX = [tmpArr copy];

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
    //tank = (SKShapeNode *)[self childNodeWithName:@"//tank"];
    tankHealthLabel = (SKLabelNode*)[self childNodeWithName:@"//tankHealth"];

    // Setup the tank
    dispatch_async(arrayQueue, ^{
        self->tank = [[SKShapeNode alloc] init];
        CGSize objSize = CGSizeMake(128, 128);
        self->tank = [SKShapeNode shapeNodeWithRectOfSize:objSize];

        [self->tank setFillTexture:tankRotationTX[0]];
        [self->tank setFillColor:[NSColor whiteColor]];
        self->tank.lineWidth = 0;
        [self addChild:self->tank];
    });

    // The background demon to move the map
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            // Spawn objects
            dispatch_async(arrayQueue, ^{
                if (currentObjects < maxObjectCount) {
                    // Spawn somthing

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
                    currentObjects++;
                }

                //**************
                // Move the tank
                //**************

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

                // Set the tank health label
                [tankHealthLabel setText:[NSString stringWithFormat:@"%d", (int)tankHitPoints]];

                // Now check the hitpoints
                if (tankHitPoints <= 0) {
                    NSLog(@"Your tank is lifeless");
                    [self respawnTank];
                }

                // Now set the tank rotation

                int angle = 0;
                if (movingUp) {
                    angle = 0;
                    if (movingLeft) {
                        angle = 7;
                    } else if (movingRight) {
                        angle = 1;
                    }
                } else if (movingDown) {
                    angle = 4;
                    if (movingLeft) {
                        angle = 5;
                    } else if (movingRight) {
                        angle = 3;
                    }
                } else if (movingLeft) {
                    angle = 6;
                } else if (movingRight) {
                    angle = 2;
                }
                [self->tank setFillTexture:tankRotationTX[angle]];

                //**************************************************
                // Now check if the tank colided with another object
                //**************************************************

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
                        NSLog(@"Your tank crashed with on object");

                        [o removeFromParent];
                        [objects removeObject:o];
                        currentObjects--;

                        // Take some hit points away since it hit an object
                        tankHitPoints -= 12;
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

                        // The bullet hit an object
                        if (xprox <= crashRange && yprox <= crashRange) {
                            [o removeFromParent];
                            [objects removeObject:o];
                            [bullets removeObject:b];
                            [b removeFromParent];
                            currentObjects--;

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
                                dispatch_async(arrayQueue, ^{
                                    [fire removeFromParent];
                                });
                            });
                        }

                    }
                }

                // Now check if the bullet(s) hit another tank
                for (SKShapeNode* b in [bullets copy]) {
                    int otx = self->otherTank.position.x;
                    int oty = self->otherTank.position.y;

                    int bx = b.position.x;
                    int by = b.position.y;

                    int xprox = abs(bx - otx);
                    int yprox = abs(by - oty);

                    int crashRange = 40;

                    // The bullet hit an object
                    if (xprox <= crashRange && yprox <= crashRange) {
                        NSLog(@"You hit another tank!");
                        [b removeFromParent];
                        [bullets removeObject:b];
                    }
                }


                // Now save this player posistion to the web server
                NSDictionary* tankPosDict = [self getTankPosistion];
                [tankPosDict writeToURL:multiPlayerMyFile atomically:YES];

                // Updates the other players posistion/hitpoints
                [self getAndPlaceOtherTanks];

            });

            [NSThread sleepForTimeInterval:0.03f];
        }
    });

    // This is for the less importent stuff
    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
        // Check if the tank is still on the battle grounds
        if (fabs(self->background.position.x) > 2000 || fabs(self->background.position.y) > 2000) {
            // If the tank is off the battle grounds, then take some hitpoints!
            NSLog(@"Get back on the battle grounds!!!");
            tankHitPoints -= 10;
        }
    }];
}

- (void)respawnTank {
    dispatch_async(arrayQueue, ^{
        CGPoint pos;
        pos.x = 0;
        pos.y = 0;

        self->background.position = pos;
        tankHitPoints = 200;
    });
}

NSString* otherPlayerIPAddress = nil;

+ (void)setOtherPlayerIPAddress:(NSString*)ip {
    otherPlayerIPAddress = ip;
}

SKShapeNode* otherTankBullet = nil;
NSDate* lastTimeHit = nil;

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

            if (xprox <= crashRange && yprox <= crashRange) {
                if (lastTimeHit == nil || [lastTimeHit timeIntervalSinceNow] < -0.25) {
                    float damage = [[otherTankDict valueForKey:@"bulletDamage"] floatValue];
                    NSLog(@"YOUR TANK GOT HIT!!! -%f", damage);
                    tankHitPoints -= damage;
                    lastTimeHit = [NSDate date];
                }
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
        i++;
    }
    [dict setObject:bulls forKey:@"bullets"];

    // Set how much damage to deal to other tanks
    [dict setValue:@(bulletDamage) forKey:@"bulletDamage"];

    // Now get this tank hitpoints
    [dict setValue:@(tankHitPoints) forKey:@"tankHitPoints"];

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

        // Calculate the duration, which is determent on where you click to fire
        float dur = (fabs(pos.x) + fabs(pos.y)) / 1200;

        [bullet runAction:[SKAction repeatActionForever:[SKAction moveByX:pos.x y:pos.y duration:dur]]];
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

NSDate* lastFiredDate = nil;

- (void)startFireing {
    autoShootTimer = [NSTimer scheduledTimerWithTimeInterval:0.9 repeats:YES block:^(NSTimer *timer) {
        [SoundFX SFXShootTankMed];
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
    mouseDownPos = [theEvent locationInNode:self];
}

- (void)mouseUp:(NSEvent *)theEvent {
    // [self touchUpAtPoint:[theEvent locationInNode:self]];

    [self stopFireing];
}

- (void)touchDownAtPoint:(CGPoint)pos {
    if (lastFiredDate == nil || [lastFiredDate timeIntervalSinceNow] < -0.9) {
        [SoundFX SFXShootTankMed];
        [self shootBullet:pos];
        lastFiredDate = [NSDate date];
    }
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

+ (void)setTankClass:(NSString*)tclass {
    tankClass = tclass;
}

- (NSImage *)rotateImage:(NSImage*)img toDegrees:(float)degrees {
    degrees = fmod(degrees, 360.);
    if (degrees == 0) {
        return img;
    }
    NSSize size = [img size];
    NSSize maxSize;
    if (90. == degrees || 270. == degrees || -90. == degrees || -270. == degrees) {
        maxSize = NSMakeSize(size.height, size.width);
    } else if (180. == degrees || -180. == degrees) {
        maxSize = size;
    } else {
        maxSize = size;
        //maxSize = NSMakeSize(32+MAX(size.width, size.height), 32+MAX(size.width, size.height));
    }
    NSAffineTransform *rot = [NSAffineTransform transform];
    [rot rotateByDegrees:degrees];
    NSAffineTransform *center = [NSAffineTransform transform];
    [center translateXBy:maxSize.width / 2. yBy:maxSize.height / 2.];
    [rot appendTransform:center];
    NSImage *image = [[NSImage alloc] initWithSize:maxSize];
    [image lockFocus];
    [rot concat];
    NSRect rect = NSMakeRect(0, 0, size.width, size.height);
    NSPoint corner = NSMakePoint(-size.width / 2., -size.height / 2.);
    [img drawAtPoint:corner fromRect:rect operation:NSCompositingOperationCopy fraction:1.0];
    [image unlockFocus];

    return image;
}

@end
