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
    NSMutableArray <SKShapeNode*> *objects;
}

int maxObjectCount = 2;
int currentObjects = 0;

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here

    background = (SKShapeNode *)[self childNodeWithName:@"//battleBackground"];
    tank = (SKShapeNode *)[self childNodeWithName:@"//tank"];

    // The background demon to move the map
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            // Spawn objects
            if (currentObjects < maxObjectCount) {
                // Spawn somthing

                SKShapeNode* obj = [[SKShapeNode alloc] init];

                //CGFloat w = (self.size.width + self.size.height) * 0.05;
                //obj = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.2];

                CGSize objSize = CGSizeMake(100, 100);

                obj = [SKShapeNode shapeNodeWithRectOfSize:objSize];

                NSURL* imageURL = [NSBundle.mainBundle URLForResource:@"obj1" withExtension:@"png"];
                NSImage* img = [[NSImage alloc] initWithContentsOfURL:imageURL];


                SKTexture* tx = [SKTexture textureWithImage:img];
                [obj setFillTexture:tx];
                [obj setFillColor:[NSColor whiteColor]];
                [obj setStrokeColor:[NSColor blackColor]];

                CGPoint objPos = CGPointMake(5, 5);

                //obj.position = point;

//                [self addChild:obj];
                [self->background addChild:obj];
                currentObjects++;
            }

            // Move the tank
            float speed = tankMovmentSpeed;

            if ((movingUp + movingDown + movingLeft + movingRight) >= 2) {
                speed /= 2;
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

            [NSThread sleepForTimeInterval:0.01f];
        }
    });
}


- (void)touchDownAtPoint:(CGPoint)pos {
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
