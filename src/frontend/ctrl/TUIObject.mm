//
//  TUIObject.m
//  iReacTIVision
//
//  Created by Markus Konrad on 24.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIObject.h"

@implementation TUIObject

@synthesize initialized;
@synthesize sessId;
@synthesize classId;
@synthesize pos;
@synthesize angle;

+(id)objectWithSessId:(int)s {
    return [[[[self class] alloc] initWithSessId:s] autorelease];
}

+(id)objectWithSessId:(int)s classId:(int)c pos:(CGPoint)p angle:(float)a {
    return [[[[self class] alloc] initWithSessId:s classId:c pos:p angle:a] autorelease];
}

-(id)initWithSessId:(int)s {
    self = [super init];
    
    if (self) {
        sessId = s;;
        initialized = NO;
    }

    return self;
}

-(id)initWithSessId:(int)s classId:(int)c pos:(CGPoint)p angle:(float)a {
    self = [super init];
    
    if (self) {
        sessId = s;
        classId = c;
        pos = p;
        angle = a;
        initialized = YES;
    }

    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"TUIObject #%d with class id %d at pos %f,%f / angle %f", sessId, classId, pos.x, pos.y, angle];
}

@end
