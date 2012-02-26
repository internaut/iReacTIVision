//
//  KashrutGame.h
//  iReacTIVision
//
//  Created by Markus Konrad on 25.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TUIFrontendCore.h"
#import "TUIObjectObserver.h"

#import "KashrutFoodObject.h"

#import "KashrutGameTypes.h"

@interface KashrutGame : NSObject<TUIObjectObserver> {
    NSMutableDictionary *foodAreas;     // dictionary with mapping NSNumber (KashrutGameFoodType) -> NSValue (CGRect area)
    NSDictionary *foodObjectTypes;      // dictionary with mapping NSNumber (TUIObject class id) -> NSNumber (KashrutGameFoodType) 
    NSMutableDictionary *foodObjects;   // dictionary with mapping NSNumber (TUIObject class id) -> KashrutFoodObject
}

@property (nonatomic,assign) TUIFrontendCore *core;

-(void)setFoodArea:(CGRect)area forType:(KashrutGameFoodType)type;

@end
