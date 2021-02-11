//
//  ViewController.m
//  ShootTheTank
//
//  Created by Westley Rose on 2/6/21.
//

#import "ViewController.h"
#import "GameScene.h"

@implementation ViewController

// The amount of upgrade points avalible
NSInteger upgradePointPool = 50;

int tankClassIndex = 0;
NSArray <NSString*>* tankClasses;

int bulletDamageBarValue = 0;
int bulletSpeedBarValue = 0;
int tankArmorBarValue = 0;
int maxHitpointsBarValue = 0;
int tankSpeedBarValue = 0;
int tankCamoBarValue = 0;

- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];

    // Setup the tank classes
    tankClasses = @[@"Gen-Eric", @"Zipper", @"Snail", @"Snipper", @"Destroyer"];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* lastIPAddress = [defaults valueForKey:@"LastIPAddress"];
    if (lastIPAddress == nil) lastIPAddress = @"";
    [self.ipAddressTextField setStringValue:lastIPAddress];

    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
    self.UTPClassNameLabel.stringValue = tankClasses[tankClassIndex];

    // Bullet damage bar
    [self.UTPBulletDamageBar setIntValue:bulletDamageBarValue];
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}

- (IBAction)createGameAction:(id)sender {
    NSLog(@"%s", __func__);

    [GameScene setIsMasterGame:YES];

    [self.gameMenuView setHidden:YES];

    if (![self.ipAddressTextField.stringValue isEqualToString:@""]) {
        // Set the IP address
        [GameScene setOtherPlayerIPAddress:self.ipAddressTextField.stringValue];
    }

    [self loadGameScene];
}

- (IBAction)joinGameAction:(id)sender {
    NSLog(@"%s", __func__);

    [self.gameMenuView setHidden:YES];

    if (![self.ipAddressTextField.stringValue isEqualToString:@""]) {
        // Set the IP address
        [GameScene setOtherPlayerIPAddress:self.ipAddressTextField.stringValue];
    }

    [self loadGameScene];
}

- (void)loadGameScene {
    NSLog(@"%s", __func__);

    // Save the last IP address used
    [[NSUserDefaults standardUserDefaults] setValue:self.ipAddressTextField.stringValue forKey:@"LastIPAddress"];

    // Load the SKScene from 'GameScene.sks'
    GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];

    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;

    // Present the scene
    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

//*******************
// Upgrade tank popup
//*******************


// Class buttons
// TODO: add the images
- (IBAction)UTPClassLeft:(id)sender {
    tankClassIndex--;
    if (tankClassIndex < 0) {
        tankClassIndex = (int)tankClasses.count-1;
    }

    self.UTPClassNameLabel.stringValue = tankClasses[tankClassIndex];
}

- (IBAction)UTPClassRight:(id)sender {
    tankClassIndex++;
    if (tankClassIndex > tankClasses.count-1) {
        tankClassIndex = 0;
    }

    self.UTPClassNameLabel.stringValue = tankClasses[tankClassIndex];
}

// Bullet damage
- (IBAction)UTPBDPlusAction:(id)sender {
    if (upgradePointPool < 5) return;

    if (bulletDamageBarValue + 1 > self.UTPBulletDamageBar.maxValue) {
        return;
    }

    bulletDamageBarValue++;

    [self.UTPBulletDamageBar setIntValue:bulletDamageBarValue];

    upgradePointPool -= 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}
- (IBAction)UTPBDMinuseAction:(id)sender {
    if (bulletDamageBarValue - 1 < 0) {
        return;
    }

    bulletDamageBarValue--;

    [self.UTPBulletDamageBar setIntValue:bulletDamageBarValue];

    upgradePointPool += 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}

// Bullet speed
- (IBAction)UTPBSPlusAction:(id)sender {
    if (upgradePointPool < 5) return;

    if (bulletSpeedBarValue + 1 > self.UTPBulletSpeedBar.maxValue) {
        return;
    }

    bulletSpeedBarValue++;

    [self.UTPBulletSpeedBar setIntValue:bulletSpeedBarValue];

    upgradePointPool -= 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}
- (IBAction)UTPBSMinusAction:(id)sender {
    if (bulletSpeedBarValue - 1 < 0) {
        return;
    }

    bulletSpeedBarValue--;

    [self.UTPBulletSpeedBar setIntValue:bulletSpeedBarValue];

    upgradePointPool += 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}

// Tank armor
- (IBAction)UTPTAPlusAction:(id)sender {
    if (upgradePointPool < 5) return;

    if (tankArmorBarValue + 1 > self.UTPArmorBar.maxValue) {
        return;
    }

    tankArmorBarValue++;

    [self.UTPArmorBar setIntValue:tankArmorBarValue];

    upgradePointPool -= 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}
- (IBAction)UTPTAMinusAction:(id)sender {
    if (tankArmorBarValue - 1 < 0) {
        return;
    }

    tankArmorBarValue--;

    [self.UTPArmorBar setIntValue:tankArmorBarValue];

    upgradePointPool += 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}

// Max hitpoints
- (IBAction)UTPMHPlusAction:(id)sender {
    if (upgradePointPool < 5) return;

    if (maxHitpointsBarValue + 1 > self.UTPMaxHitpointsBar.maxValue) {
        return;
    }

    maxHitpointsBarValue++;

    [self.UTPMaxHitpointsBar setIntValue:maxHitpointsBarValue];

    upgradePointPool -= 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}
- (IBAction)UTPMHMinusAction:(id)sender {
    if (maxHitpointsBarValue - 1 < 0) {
        return;
    }

    maxHitpointsBarValue--;

    [self.UTPMaxHitpointsBar setIntValue:maxHitpointsBarValue];

    upgradePointPool += 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}

// Tank speed
- (IBAction)UTPTSPlusAction:(id)sender {
    if (upgradePointPool < 5) return;

    if (tankSpeedBarValue + 1 > self.UTPTankSpeedBar.maxValue) {
        return;
    }

    tankSpeedBarValue++;

    [self.UTPTankSpeedBar setIntValue:tankSpeedBarValue];

    upgradePointPool -= 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}
- (IBAction)UTPTSMinusAction:(id)sender {
    if (tankSpeedBarValue - 1 < 0) {
        return;
    }

    tankSpeedBarValue--;

    [self.UTPTankSpeedBar setIntValue:tankSpeedBarValue];

    upgradePointPool += 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}

// Tank camo
- (IBAction)UTPTCPlusAction:(id)sender {
    if (upgradePointPool < 10) return;

    if (tankCamoBarValue + 1 > self.UTPCamoBar.maxValue) {
        return;
    }

    tankCamoBarValue++;

    [self.UTPCamoBar setIntValue:tankCamoBarValue];

    upgradePointPool -= 10;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}
- (IBAction)UTPTCMinusAction:(id)sender {
    if (tankCamoBarValue - 1 < 0) {
        return;
    }

    tankCamoBarValue--;

    [self.UTPCamoBar setIntValue:tankCamoBarValue];

    upgradePointPool += 10;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}

@end
