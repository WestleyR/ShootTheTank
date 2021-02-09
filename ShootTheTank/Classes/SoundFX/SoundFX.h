//
//  SoundFX.h
//  ShootTheTank
//
//  Created by Westley Rose on 2021-02-08.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SoundFX : NSObject

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

+ (void)SFXShootTank;

@end

NS_ASSUME_NONNULL_END
