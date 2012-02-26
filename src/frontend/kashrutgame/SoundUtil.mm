//
//  SoundUtil.m
//  iReacTIVision
//
//  Created by Markus Konrad on 26.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundUtil.h"

@implementation SoundUtil

#pragma mark init/dealloc

-(id)init {
    self = [super init];
    
    if (self) {
        sounds = [[NSMutableSet alloc] init];
    }

    return self;
}

-(void)dealloc {
    [self unloadAllSounds];

    [sounds release];

    [super dealloc];
}

#pragma mark public methods

-(SystemSoundID)loadSound:(NSString *)sndFile {
    NSString *sndURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], sndFile] isDirectory:NO];
    
    SystemSoundID sndId;
    
    if (AudioServicesCreateSystemSoundID((CFURLRef)sndURL, &sndId) == kAudioServicesNoError) {
        [sounds addObject:[NSNumber numberWithInt:sndId]];
    } else {
        sndId = 0;
    }
    
    return sndId;
}

-(BOOL)unloadSound:(SystemSoundID)sndId {
    if (sndId > 0 && AudioServicesDisposeSystemSoundID(sndId) == kAudioServicesNoError) {        
        [sounds removeObject:[NSNumber numberWithInt:sndId]];
    
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)unloadAllSounds {
    for (NSNumber *sndId in sounds) {
        AudioServicesDisposeSystemSoundID([sndId unsignedIntValue]);
    }
    
    [sounds removeAllObjects];
    
    return YES;
}

-(BOOL)playSound:(SystemSoundID)sndId {
    if (sndId > 0) {
        AudioServicesPlaySystemSound(sndId);
    
        return YES;
    }
    
    return NO;
}

#pragma mark singleton stuff

static SoundUtil *sharedObject;

+ (SoundUtil *)shared {
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;    
}

- (void)destroy {
    [sharedObject dealloc];
    sharedObject = nil;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self shared] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


@end
