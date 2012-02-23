//
//  TUIFrontendCore.h
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Singleton.h"

#include "TUIOMsgListener.h"
#include "UdpSocket.h"

@interface TUIFrontendCore : NSObject<Singleton> {
    TUIOMsgListener *msgListener;
    UdpListeningReceiveSocket *sock;
}

@property (nonatomic,assign) int port;

-(void)start;
-(void)stop;

@end
