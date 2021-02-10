//
//  SoundFX.m
//  ShootTheTank
//
//  Created by Westley Rose on 2021-02-08.
//

#import "SoundFX.h"

@implementation SoundFX

SystemSoundID tankFireMedFX = 0;
SystemSoundID tankFireLightFX = 0;
SystemSoundID fireBurningFX = 0;
SystemSoundID engineFX = 0;

// TODO: Make these functions a little nicer

+ (void)SFXShootTankMed {
    NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"fire_med" withExtension:@"mp3"];

    if (tankFireMedFX == 0) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &tankFireMedFX);
    }

    AudioServicesPlaySystemSound(tankFireMedFX);
}

+ (void)SFXShootTankLight {
    NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"fire_light" withExtension:@"mp3"];

    if (tankFireLightFX == 0) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &tankFireMedFX);
    }

    AudioServicesPlaySystemSound(tankFireLightFX);
}

+ (void)SFXFireBurning {
    NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"fire_burning" withExtension:@"mp3"];

    if (fireBurningFX == 0) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &fireBurningFX);
    }

    AudioServicesPlaySystemSound(fireBurningFX);
}

+ (void)SFXEngine {
    NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"engine" withExtension:@"mp3"];

    if (engineFX == 0) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &engineFX);
    }

    AudioServicesPlaySystemSound(engineFX);
}

@end
