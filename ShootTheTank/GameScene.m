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
}

NSMutableArray <SKShapeNode*>* objects;
NSMutableArray <SKShapeNode*>* bullets;

int maxObjectCount = 100;
int currentObjects = 0;

dispatch_queue_t arrayQueue;

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here

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
            if (currentObjects < maxObjectCount) {
                // Spawn somthing

                SKShapeNode* obj = [[SKShapeNode alloc] init];

                CGSize objSize = CGSizeMake(80, 80);

                obj = [SKShapeNode shapeNodeWithRectOfSize:objSize];

                NSURL* imageURL = [NSBundle.mainBundle URLForResource:@"obj1" withExtension:@"png"];
                NSImage* img = [[NSImage alloc] initWithContentsOfURL:imageURL];

                SKTexture* tx = [SKTexture textureWithImage:img];
                [obj setFillTexture:tx];
                [obj setFillColor:[NSColor whiteColor]];
                [obj setStrokeColor:[NSColor blackColor]];

                CGPoint objPos = [self ranPoint];
                obj.position = objPos;

                dispatch_async(arrayQueue, ^{
                    [self->background addChild:obj];
                    [objects addObject:obj];
                });
                currentObjects++;
            }

            // Move the tank
            float speed = tankMovmentSpeed;

            if ((movingUp + movingDown + movingLeft + movingRight) >= 2) {
                speed /= 1.25;
            }

            if (movingUp) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    CGPoint newPos = self->background.position;
                    newPos.y -= speed;
                    [self->background setPosition:newPos];
                });
            }
            if (movingDown) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    CGPoint newPos = self->background.position;
                    newPos.y += speed;
                    [self->background setPosition:newPos];
                });
            }
            if (movingLeft) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    CGPoint newPos = self->background.position;
                    newPos.x += speed;
                    [self->background setPosition:newPos];
                });
            }
            if (movingRight) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    CGPoint newPos = self->background.position;
                    newPos.x -= speed;
                    [self->background setPosition:newPos];
                });
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
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self->tank setZRotation:rad];
            });


            // Now check if the tank colided with another object
            dispatch_async(arrayQueue, ^{
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

                    [o removeFromParent];
                    [objects removeObject:o];
                    currentObjects--;
                }
            }
            });

            [NSThread sleepForTimeInterval:0.01f];
        }
    });
}

- (int)ranNumFrom:(int)min to:(int)max {
    return min + arc4random_uniform((uint32_t)(max - min + 1));
}

- (NSPoint)ranPoint {
    NSPoint p;
    p.x = [self ranNumFrom:-1024 to:1024];
    p.y = [self ranNumFrom:-1024 to:1024];

    return p;
}


- (void)touchDownAtPoint:(CGPoint)pos {
    CGPoint startPos = background.position;
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

    __block bool isAlive = YES;

    [bullet runAction:[SKAction repeatActionForever:[SKAction moveByX:pos.x y:pos.y duration:0.5]]];
    [bullet runAction:[SKAction sequence:@[
                       [SKAction waitForDuration:2.5],
                       [SKAction fadeOutWithDuration:0.1],
                       [SKAction removeFromParent]]]
           completion:^{
        //isAlive = NO;

        dispatch_async(arrayQueue, ^{
            [bullets removeObject:bullet];
        });
    }];

    bullet.position = startPos;

    [background addChild:bullet];
    dispatch_async(arrayQueue, ^{
        [bullets addObject:bullet];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
    //        NSLog(@"BULLET: %d->%d", (int)bullet.position.x, (int)bullet.position.y);

            dispatch_async(arrayQueue, ^{

                // Now check if the tank colided with another object
                for (SKShapeNode* o in [objects copy]) {
                    if (o == nil) break;
                    for (SKShapeNode* b in [bullets copy]) {
                        if (b == nil) break;

                        int crashRange = 70;

                        int x = o.position.x;
                        int y = o.position.y;

                        int bx = b.position.x;
                        int by = b.position.y;

                        //NSLog(@"TANK: %d->%d", bx, by);
                        //(@"OBJ: %d->%d", x, y);

                        int xprox = abs(bx - x);
                        int yprox = abs(by - y);

                        //NSLog(@"TANK PROX: %d->%d", xprox, yprox);
                        if (xprox <= crashRange && yprox <= crashRange) {
                            NSLog(@"CRASH");

                            [o removeFromParent];
                            [objects removeObject:o];
                            [bullets removeObject:b];
                            [b removeFromParent];
                            currentObjects--;
                            //isAlive = NO;
                        }
                    }
                }
            });
            [NSThread sleepForTimeInterval:0.01f];
        }
    });

//    SKShapeNode *n = [_spinnyNode copy];
//    n.position = pos;
//    n.strokeColor = [SKColor greenColor];
//    [self addChild:n];
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



- (void)mouseDown:(NSEvent *)theEvent {
    [self touchDownAtPoint:[theEvent locationInNode:self]];
}
- (void)mouseDragged:(NSEvent *)theEvent {
    [self touchMovedToPoint:[theEvent locationInNode:self]];
}
- (void)mouseUp:(NSEvent *)theEvent {
   // [self touchUpAtPoint:[theEvent locationInNode:self]];
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
