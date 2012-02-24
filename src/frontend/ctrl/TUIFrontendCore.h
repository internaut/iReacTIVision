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

#include "TUIOMsgListener.h"
#include "UdpSocket.h"

@interface TUIFrontendCore : NSObject<Singleton> {
    TUIOMsgListener *msgListener;
    UdpListeningReceiveSocket *sock;
    NSMutableDictionary *tuiObjects;    // dictionary with mapping: NSNumber sessId -> TUIObject
    NSMutableSet *tuiObjectObservers;   // set with id<TUIObjectObserver> objects
}

@property (nonatomic,assign) int port;
@property (atomic,readonly) NSDictionary *tuiObjects;

-(void)start;
-(void)stop;

-(void)addTUIObjectObserver:(id<TUIObjectObserver>)observer;
-(void)removeTUIObjectObserver:(id<TUIObjectObserver>)observer;

-(void)receivedTUIOMsg:(TUIOMsg *)msg;

@end
