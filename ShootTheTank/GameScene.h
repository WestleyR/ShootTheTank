//
//  GameScene.h
//  ShootTheTank
//
//  Created by Westley Rose on 2/6/21.
//

#import <SpriteKit/SpriteKit.h>

#import "AppDelegate.h"

#import "Classes/SoundFX/SoundFX.h"

@interface GameScene : SKScene

+ (void)setOtherPlayerIPAddress:(NSString*)ip;
+ (void)setIsMasterGame:(BOOL)master;

@end
