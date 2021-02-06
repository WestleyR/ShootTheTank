//
//  GameScene.m
//  ShootTheTank
//
//  Created by Westley Rose on 2/6/21.
//

#import "GameScene.h"

@implementation GameScene {
    SKShapeNode *_spinnyNode;
    SKShapeNode* background;
    SKLabelNode *_label;
}

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here

    //_label.alpha = 0.0;
    //[_label runAction:[SKAction fadeInWithDuration:2.0]];

    background = (SKShapeNode *)[self childNodeWithName:@"//battleBackground"];

    CGFloat w = (self.size.width + self.size.height) * 0.05;
    
    // Create shape node to use during mouse interaction
//    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.6];
    _spinnyNode.lineWidth = 5.5;
    
//    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
//    [_spinnyNode runAction:[SKAction sequence:@[
//                                                [SKAction waitForDuration:0.5],
//                                                [SKAction fadeOutWithDuration:0.5],
//                                                [SKAction removeFromParent],
//                                                ]]];

//    SKShapeNode *n = [_spinnyNode copy];
    CGPoint pos = CGPointMake(5, 5);
    _spinnyNode.position = pos;
    _spinnyNode.strokeColor = [SKColor blueColor];
    [self addChild:_spinnyNode];
}


- (void)touchDownAtPoint:(CGPoint)pos {
//    SKShapeNode *n = [_spinnyNode copy];
//    n.position = pos;
//    n.strokeColor = [SKColor greenColor];
//    [self addChild:n];
}

- (void)touchMovedToPoint:(CGPoint)pos {
    _spinnyNode.position = pos;

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

int tankMovmentSpeed = 8;

- (void)keyDown:(NSEvent *)theEvent {

    CGPoint newPos;
    switch (theEvent.keyCode) {
        case 0x31 /* SPACE */:
            // Run 'Pulse' action from 'Actions.sks'
            [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
            break;

        case 0x0D: // up
            NSLog(@"%s UP", __func__);
            newPos = background.position;
            newPos.y -= tankMovmentSpeed;
            [background setPosition:newPos];
            break;

        case 0x01: // down
            newPos = background.position;
            newPos.y += tankMovmentSpeed;
            [background setPosition:newPos];
            break;

        case 0x02: // right
            newPos = background.position;
            newPos.x -= tankMovmentSpeed;
            [background setPosition:newPos];
            break;

        case 0x00: // left
            newPos = background.position;
            newPos.x += tankMovmentSpeed;
            [background setPosition:newPos];
            break;

        default:
            NSLog(@"keyDown:'%@' keyCode: 0x%02X", theEvent.characters, theEvent.keyCode);
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
