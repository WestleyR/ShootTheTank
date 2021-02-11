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
@property (weak) IBOutlet NSImageView *tankImage;

//*******************
// Upgrade tank popup
//*******************

@property (weak) IBOutlet NSImageView *UTPTankClassImage;
@property (weak) IBOutlet NSTextField *UTPClassNameLabel;

@property (weak) IBOutlet NSLevelIndicator *UTPBulletDamageBar;
@property (weak) IBOutlet NSLevelIndicator *UTPBulletSpeedBar;
@property (weak) IBOutlet NSLevelIndicator *UTPBulletFireRateBar;
@property (weak) IBOutlet NSLevelIndicator *UTPArmorBar;
@property (weak) IBOutlet NSLevelIndicator *UTPMaxHitpointsBar;
@property (weak) IBOutlet NSLevelIndicator *UTPTankSpeedBar;
@property (weak) IBOutlet NSLevelIndicator *UTPCamoBar;

@property (weak) IBOutlet NSTextField *UTPRemaningPointsLabel;


@end

