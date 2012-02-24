//
//  TUIObject.h
//  iReacTIVision
//
//  Created by Markus Konrad on 24.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TUIObject : NSObject

@property (nonatomic,assign) BOOL initialized;   // is YES if we got a "SET" message and the coordinates were set
@property (nonatomic,assign) int sessId;
@property (nonatomic,assign) int classId;
@property (nonatomic,assign) CGPoint pos;
@property (nonatomic,assign) float angle;

+(id)objectWithSessId:(int)s;    // will be an unintialized object
+(id)objectWithSessId:(int)s classId:(int)c pos:(CGPoint)p angle:(float)a;  // will be an initialized object

-(id)initWithSessId:(int)s;      // will be an unintialized object
-(id)initWithSessId:(int)s classId:(int)c pos:(CGPoint)p angle:(float)a;      // will be an initialized object

@end
