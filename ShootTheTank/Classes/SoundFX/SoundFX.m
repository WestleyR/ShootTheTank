//
//  SoundFX.m
//  ShootTheTank
//
//  Created by Westley Rose on 2021-02-08.
//

#import "SoundFX.h"

@implementation SoundFX

NSSound* tankFireSoundMed = nil;

- (void)foo {
    NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"fire_med" withExtension:@"mp3"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (self.audioPlayer == nil) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    }

    [self.audioPlayer stop];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    });
}

SoundFX* ins = nil;

+ (void)SFXShootTank {

//        NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"fire_med" withExtension:@"mp3"];
//        tankFireSoundMed = [[NSSound alloc] initWithContentsOfURL:soundFileURL byReference:NO];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    [tankFireSoundMed play];
//    });

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL* soundFileURL = [NSBundle.mainBundle URLForResource:@"fire_med" withExtension:@"mp3"];
            tankFireSoundMed = [[NSSound alloc] initWithContentsOfURL:soundFileURL byReference:NO];

            [tankFireSoundMed play];
        });


//    if (ins == nil) {
//        ins = [[SoundFX alloc] init];
//    }
//    [ins foo];


//    AVAudioPlayer* bombSoundEffect = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
//    [bombSoundEffect play];


}

@end
