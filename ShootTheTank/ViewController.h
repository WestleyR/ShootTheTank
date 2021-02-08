//
//  ViewController.h
//  ShootTheTank
//
//  Created by Westley Rose on 2/6/21.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

#import "GameScene.h"

@interface ViewController : NSViewController

@property (assign) IBOutlet SKView *skView;
@property (weak) IBOutlet NSView *gameMenuView;
@property (weak) IBOutlet NSTextField *ipAddressTextField;

@end

