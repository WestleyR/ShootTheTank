//
//  ViewController.m
//  ShootTheTank
//
//  Created by Westley Rose on 2/6/21.
//

#import "ViewController.h"
#import "GameScene.h"

@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];
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

    // Load the SKScene from 'GameScene.sks'
    GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];

    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;

    // Present the scene
    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

@end
