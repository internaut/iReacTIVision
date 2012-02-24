//
//  AudioController.m
//  iReacTIVision
//
//  Created by Markus Konrad on 24.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioController.h"

@interface AudioController()
#ifdef DEBUG
-(void)dbgListObjects;
#endif
@end

@implementation AudioController

@synthesize core;

#pragma mark init/dealloc

-(id)init {
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

-(void)dealloc {
    [super dealloc];
}

#pragma mark TUIObjectObserver methods

-(void)addedTUIObject:(TUIObject *)obj {
#ifdef DEBUG
    [self dbgListObjects];
#endif
}

-(void)updatedTUIObject:(TUIObject *)obj velocityVec:(CGPoint)vel rotationVelocity:(float)rot motionAccel:(float)motAcc rotationAccel:(float)rotAccel {
#ifdef DEBUG
    [self dbgListObjects];
#endif
}

-(void)removedTUIObject:(TUIObject *)obj {
#ifdef DEBUG
    [self dbgListObjects];
#endif
}

#pragma mark private methods


#ifdef DEBUG
-(void)dbgListObjects {
    NSLog(@"---");
    NSLog(@"Currently known TUIO objects: ");
    
    for (TUIObject *obj in [core.tuiObjects allValues]) {
        NSLog(@"%@", obj);
    }
    
    NSLog(@"---"); 
}
#endif

@end
