//
//  KashrutFoodObject.h
//  iReacTIVision
//
//  Created by Markus Konrad on 25.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import "TUIObject.h"

#import "KashrutGameTypes.h"

@interface KashrutFoodObject : TUIObject

@property (nonatomic, readonly) KashrutGameFoodType foodType;
@property (nonatomic, assign) KashrutGameFoodType locationFoodType;

+(id)foodObjectWithTUIObject:(TUIObject *)obj withType:(KashrutGameFoodType)type;

-(id)initWithTUIObject:(TUIObject *)obj withType:(KashrutGameFoodType)type;

-(void)updateWithTUIObject:(TUIObject *)obj;

@end
