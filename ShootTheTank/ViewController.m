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
NSInteger upgradePointPool = 30;

int tankClassIndex = 0;
NSArray <NSString*>* tankClasses;

int bulletDamageBarValue = 0;
int bulletSpeedBarValue = 0;
int bulletFireRateBarValue = 0;
int tankArmorBarValue = 0;
int maxHitpointsBarValue = 0;
int tankSpeedBarValue = 0;
int tankCamoBarValue = 0;

- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];

    // Setup the tank classes
    tankClasses = @[@"Gen-Eric", @"Zipper", @"Snail", @"Snipper", @"Destroyer"];

    // Set the background color for the menu view
    CGColorRef bgColor = CGColorCreateSRGB(0.3, 0.3, 0.3, 1);
    [self.gameMenuView setWantsLayer:YES];
    [self.gameMenuView.layer setBackgroundColor:bgColor];

    // Get the last saved IP address
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* lastIPAddress = [defaults valueForKey:@"LastIPAddress"];
    if (lastIPAddress == nil) lastIPAddress = @"";
    [self.ipAddressTextField setStringValue:lastIPAddress];

    // GUI preps
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
    self.UTPClassNameLabel.stringValue = tankClasses[tankClassIndex];

    // Bullet damage bar
    [self.UTPBulletDamageBar setIntValue:bulletDamageBarValue];
    [self.UTPBulletSpeedBar setIntValue:bulletSpeedBarValue];
    [self.UTPBulletFireRateBar setIntValue:bulletFireRateBarValue];
    [self.UTPArmorBar setIntValue:tankArmorBarValue];
    [self.UTPMaxHitpointsBar setIntValue:maxHitpointsBarValue];
    [self.UTPTankSpeedBar setIntValue:tankSpeedBarValue];
    [self.UTPCamoBar setIntValue:tankCamoBarValue];

    self.UTPTankClassImage.image = [self getTankClassImageForIndex:tankClassIndex];
    [self.tankImage setImage:[self getTankClassImageForIndex:tankClassIndex]];

    // TODO: I dont know why I need to run a timer like this, just updating the image after swiching does not work.
    __block NSTimer* updateGUI = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
        [self.tankImage setImage:[self getTankClassImageForIndex:tankClassIndex]];

        if (self.gameMenuView.isHidden) {
            NSLog(@"%s stopping background timer", __func__);
            [updateGUI invalidate];
        }
    }];
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
- (IBAction)UTPClassLeft:(id)sender {
    tankClassIndex--;
    if (tankClassIndex < 0) {
        tankClassIndex = (int)tankClasses.count-1;
    }

    self.UTPClassNameLabel.stringValue = tankClasses[tankClassIndex];
    self.UTPTankClassImage.image = [self getTankClassImageForIndex:tankClassIndex];
}

- (IBAction)UTPClassRight:(id)sender {
    tankClassIndex++;
    if (tankClassIndex > tankClasses.count-1) {
        tankClassIndex = 0;
    }

    self.UTPClassNameLabel.stringValue = tankClasses[tankClassIndex];
    self.UTPTankClassImage.image = [self getTankClassImageForIndex:tankClassIndex];
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

// Bullet fire rate
- (IBAction)UTPFRPlusAction:(id)sender {
    if (upgradePointPool < 5) return;

    if (bulletFireRateBarValue + 1 > self.UTPBulletFireRateBar.maxValue) {
        return;
    }

    bulletFireRateBarValue++;

    [self.UTPBulletFireRateBar setIntValue:bulletFireRateBarValue];

    upgradePointPool -= 5;
    self.UTPRemaningPointsLabel.stringValue = [NSString stringWithFormat:@"%d points left", (int)upgradePointPool];
}
- (IBAction)UTPRFMinusAction:(id)sender {
    if (bulletFireRateBarValue - 1 < 0) {
        return;
    }

    bulletFireRateBarValue--;

    [self.UTPBulletFireRateBar setIntValue:bulletFireRateBarValue];

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

- (NSImage*)getTankClassImageForIndex:(int)index {
    NSArray* tankImageNames = @[@"GenEric", @"Zipper", @"Snail", @"Snipper", @"Destroyer"];

    if (index > tankImageNames.count) return nil;

    NSURL* imageURL = [NSBundle.mainBundle URLForResource:tankImageNames[index] withExtension:@"png"];

    return [[NSImage alloc] initWithContentsOfURL:imageURL];
}

@end
