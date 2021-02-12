//
//  SoundFX.h
//  ShootTheTank
//
//  Created by Westley Rose on 2021-02-08.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface SoundFX : NSObject

+ (void)SFXShootTankMed;
+ (void)SFXShootTankLight;
+ (void)SFXShootTankSnipper;
+ (void)SFXFireBurning;
+ (void)SFXEngine;

@end

NS_ASSUME_NONNULL_END
