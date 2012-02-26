//
//  KashrutGame.m
//  iReacTIVision
//
//  Created by Markus Konrad on 25.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KashrutGame.h"

#import "SoundUtil.h"

@interface KashrutGame()

#ifdef DEBUG
-(void)dbgListObjects;
#endif

-(void)checkFood:(KashrutFoodObject *)food;

-(void)food:(KashrutFoodObject *)food movedFromAreaType:(KashrutGameFoodType)oldType toAreaType:(KashrutGameFoodType)newType;

@end

@implementation KashrutGame

@synthesize core;

#pragma mark init/dealloc

-(id)init {
    self = [super init];
    
    if (self) {
        foodAreas = [[NSMutableDictionary alloc] init];
        foodObjects = [[NSMutableDictionary alloc] init];
        
        // hard coded for now... todo: get from PLIST
        foodObjectTypes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithInt:kKashrutGameFoodTypeNeutral], [NSNumber numberWithInt:24],
            [NSNumber numberWithInt:kKashrutGameFoodTypeUnkosher], [NSNumber numberWithInt:25],
            nil];
            
        // hard coded for now... todo: get from PLIST
        [self setFoodArea:CGRectMake(0.0f, 0.0f, 0.5f, 1.0f) forType:kKashrutGameFoodTypeNeutral];
        [self setFoodArea:CGRectMake(0.5f, 0.0f, 0.5f, 1.0f) forType:kKashrutGameFoodTypeUnkosher];
        
        // load sounds
        // success sound by "grunz" from http://www.freesound.org/people/grunz/sounds/109662/
        SoundUtil *sound = [SoundUtil shared];
        successSnd = [sound loadSound:@"success.wav"];
        failureSnd = [sound loadSound:@"failure.wav"];
        
        NSLog(@"KashrutGame: Initialized");
    }
    
    return self;
}

-(void)dealloc {
    [core.sound unloadSound:successSnd];
    [core.sound unloadSound:failureSnd];
    
    [foodObjectTypes release];
    [foodAreas release];
    [foodObjects release];

    [super dealloc];
}

#pragma mark public methods

-(void)setFoodArea:(CGRect)area forType:(KashrutGameFoodType)type {
    [foodAreas setObject:[NSValue valueWithCGRect:area] forKey:[NSNumber numberWithInt:type]];
}

#pragma mark TUIObjectObserver methods

-(void)addedTUIObject:(TUIObject *)obj {
    NSLog(@"KashrutGame: Adding object#%d (class id %d)", obj.sessId, obj.classId);
//#ifdef DEBUG
//    [self dbgListObjects];
//#endif
}

-(void)updatedTUIObject:(TUIObject *)obj
            velocityVec:(CGPoint)vel
       rotationVelocity:(float)rot
            motionAccel:(float)motAcc
          rotationAccel:(float)rotAccel
        justInitialized:(BOOL)justInitialized {
    NSLog(@"KashrutGame: Updating object#%d (class id %d)", obj.sessId, obj.classId);
#ifdef DEBUG
    [self dbgListObjects];
#endif
    
    NSNumber *classId = [NSNumber numberWithInt:obj.classId];
    KashrutFoodObject *foodObj = nil;
    
    if (justInitialized) {  // TUIO object has just got intialized -> create a food object
        NSNumber *foodTypeNumber = [foodObjectTypes objectForKey:classId];
        if (foodTypeNumber) {
            foodObj = [KashrutFoodObject foodObjectWithTUIObject:obj withType:(KashrutGameFoodType)[foodTypeNumber intValue]];
            [foodObjects setObject:foodObj forKey:[NSNumber numberWithInt:foodObj.classId]];
        } else {
            NSLog(@"KashrutGame: Could not identify food type for class id %d", obj.classId);
        }
    } else {    // we have an already known object
        foodObj = [foodObjects objectForKey:classId];
        [foodObj updateWithTUIObject:obj];
        
        if (!foodObj) {
            NSLog(@"KashrutGame: Could not find food object for class id %d", obj.classId);
        }
    }
    
    // now check the food
    if (foodObj) {
        [self checkFood:foodObj];
    }
}

-(void)removedTUIObject:(TUIObject *)obj {
    NSLog(@"KashrutGame: Removing object#%d (class id %d)", obj.sessId, obj.classId);
//#ifdef DEBUG
//    [self dbgListObjects];
//#endif

    [foodObjects removeObjectForKey:[NSNumber numberWithInt:obj.classId]];
}

#pragma mark private methods

-(void)checkFood:(KashrutFoodObject *)food {
    KashrutGameFoodType foundLocationType;
    
    // check in which area this food is located
    for (NSNumber *areaType in [foodAreas allKeys]) {
        CGRect areaRect = [[foodAreas objectForKey:areaType] CGRectValue];
        
        if (CGRectContainsPoint(areaRect, food.pos)) {  // we found the location!
            foundLocationType = (KashrutGameFoodType)[areaType intValue];
            
//            NSLog(@"KashrutGame: Food object with class id %d checked. Pos is %f, %f. Area is %f, %f, %f, %f. Old location: %d, new location: %d", food.classId, food.pos.x, food.pos.y, areaRect.origin.x, areaRect.origin.y, areaRect.size.width, areaRect.size.height, food.locationFoodType, foundLocationType);            
            
            break;
        }
    }
    
    // if the food location type has changed, give feedback to the user!
    if (food.locationFoodType != foundLocationType) {
        [self food:food movedFromAreaType:food.locationFoodType toAreaType:foundLocationType];
    }
}

-(void)food:(KashrutFoodObject *)food movedFromAreaType:(KashrutGameFoodType)oldType toAreaType:(KashrutGameFoodType)newType {
    if (newType != food.foodType) {
        NSLog(@"KashrutGame: Wrong placed food with class id %d", food.classId);
        
        [core.sound playSound:failureSnd];
    } else {
        NSLog(@"KashrutGame: Correctly placed food with class id %d", food.classId);    
        
        [core.sound playSound:successSnd];
    }
    
    [food setLocationFoodType:newType];
}

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
