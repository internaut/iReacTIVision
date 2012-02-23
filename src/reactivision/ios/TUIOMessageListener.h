//
//  TUIOMessageListener.h
//  iReacTIVision
//
//  Created by Markus Konrad on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncUdpSocket.h"

@interface TUIOMessageListener : NSObject<AsyncUdpSocketDelegate> {
    AsyncUdpSocket *sock;
}



@end
