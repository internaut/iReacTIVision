//
//  KashrutFoodObject.m
//  iReacTIVision
//
//  Created by Markus Konrad on 25.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KashrutFoodObject.h"

@implementation KashrutFoodObject

@synthesize locationFoodType;
@synthesize foodType;

+(id)foodObjectWithTUIObject:(TUIObject *)obj withType:(KashrutGameFoodType)type {
    return [[[self class] alloc] initWithTUIObject:obj withType:type];
}

-(id)initWithTUIObject:(TUIObject *)obj withType:(KashrutGameFoodType)type {
    self = [super initWithSessId:obj.sessId classId:obj.classId pos:obj.pos angle:obj.angle];
    
    if (self) {
        foodType = type;
        locationFoodType = kKashrutGameFoodTypeUnknown;
    }
    
    return self;
}

-(void)updateWithTUIObject:(TUIObject *)obj {
    [self setPos:obj.pos];
    [self setAngle:obj.angle];
}

@end
