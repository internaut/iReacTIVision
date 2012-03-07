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

@class TUIFrontendCore;

@interface KashrutGame : NSObject<TUIObjectObserver> {
    NSMutableDictionary *foodAreas;     // dictionary with mapping NSNumber (KashrutGameFoodType) -> NSValue (CGRect area)
    NSDictionary *foodObjectTypes;      // dictionary with mapping NSNumber (TUIObject class id) -> NSNumber (KashrutGameFoodType) 
    NSMutableDictionary *foodObjects;   // dictionary with mapping NSNumber (TUIObject sess id) -> KashrutFoodObject
    
    SystemSoundID successSnd;
    SystemSoundID failureSnd;
    
    UIView *foodAreaOverlay;
}

@property (nonatomic,assign) TUIFrontendCore *core;
@property (nonatomic,readonly) UIView *foodAreaOverlay;

-(void)loadFoodAreas;
-(void)setFoodArea:(CGRect)area forType:(KashrutGameFoodType)type;

-(void)displayFoodAreaOverlay;
-(void)hideFoodAreaOverlay;
-(void)toggleDisplay;

@end
