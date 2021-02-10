//
//  SoundFX.m
//  ShootTheTank
//
//  Created by Westley Rose on 2021-02-08.
//

#import "SoundFX.h"

@implementation SoundFX

SystemSoundID tankFireMedFX = 0;


+ (void)SFXShootTank {
    NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"fire_med" withExtension:@"mp3"];

    if (tankFireMedFX == 0) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &tankFireMedFX);
    }

    AudioServicesPlaySystemSound(tankFireMedFX);
}

@end
