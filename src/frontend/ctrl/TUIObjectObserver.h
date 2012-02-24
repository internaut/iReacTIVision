//
//  TUIObjectEventReceiver.h
//  iReacTIVision
//
//  Created by Markus Konrad on 24.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TUIObject.h"

@protocol TUIObjectObserver <NSObject>

-(void)addedTUIObject:(TUIObject *)obj;

-(void)updatedTUIObject:(TUIObject *)obj velocityVec:(CGPoint)vel rotationVelocity:(float)rot motionAccel:(float)motAcc rotationAccel:(float)rotAccel;

-(void)removedTUIObject:(TUIObject *)obj;

@end
