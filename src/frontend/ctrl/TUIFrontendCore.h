//
//  TUIFrontendCore.h
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Singleton.h"
#import "TUIObjectObserver.h"
#import "SoundUtil.h"
#import "ControlsView.h"
#import "KashrutGame.h"

#include "TUIOMsgListener.h"
#include "UdpSocket.h"
#include "PortVideoSDL.h"

@class ControlsView;
@class KashrutGame;

@interface TUIFrontendCore : NSObject<Singleton> {
    ControlsView *controlsView;
    
    TUIOMsgListener *msgListener;
    UdpListeningReceiveSocket *sock;
    
    NSMutableDictionary *tuiObjects;    // dictionary with mapping: NSNumber sessId -> TUIObject
    NSMutableSet *tuiObjectObservers;   // set with id<TUIObjectObserver> objects
    
    KashrutGame *frontendApp;
}

@property (nonatomic,assign) int port;
@property (nonatomic,assign) PortVideoSDL *engine;
@property (atomic,readonly) NSDictionary *tuiObjects;
@property (nonatomic,readonly) SoundUtil *sound;
@property (nonatomic,readonly) ControlsView *controlsView;
@property (nonatomic,readonly) UIViewController *rootViewCtrl;
@property (nonatomic,readonly) UIView *rootView;

-(void)start;
-(void)stop;

-(void)addTUIObjectObserver:(id<TUIObjectObserver>)observer;
-(void)removeTUIObjectObserver:(id<TUIObjectObserver>)observer;

-(void)receivedTUIOMsg:(TUIOMsg *)msg;

-(void)toggleFrontendDisplay;

@end
