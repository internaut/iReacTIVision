//
//  SoundUtil.h
//  iReacTIVision
//
//  Created by Markus Konrad on 26.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>

#import "Singleton.h"

@interface SoundUtil : NSObject<Singleton> {
    NSMutableSet *sounds;   // set with NSNumbers (SystemSoundIDs) for each loaded sound
}

-(SystemSoundID)loadSound:(NSString *)sndFile;
-(BOOL)unloadSound:(SystemSoundID)sndId;
-(BOOL)unloadAllSounds;

-(BOOL)playSound:(SystemSoundID)sndId;


@end
