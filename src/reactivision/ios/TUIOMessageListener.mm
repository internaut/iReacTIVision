//
//  TUIOMessageListener.m
//  iReacTIVision
//
//  Created by Markus Konrad on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIOMessageListener.h"

@implementation TUIOMessageListener

-(id)init {
    self = [super init];
    
    if (self) {
        sock = [[AsyncUdpSocket alloc] initWithDelegate:self];
        
        NSError *sockErr;
        const int port = 3333;
        if (![sock bindToPort:port error:&sockErr]) {
            NSLog(@"TUIOMessageListener: Could not bind to port %d - %@", port, [sockErr localizedDescription]);
        } else {
            NSLog(@"TUIOMessageListener: Bind to port %d successful", port);
        }
    }

    return self;
}

-(void)dealloc {
    [sock release];

    [super dealloc];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSLog(@"TUIOMessageListener: Received UDP data with tag %ld from host %@:%d", tag, host, port);
    
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"TUIOMessageListener: Error receiving UDP data with tag %ld - %@", tag, [error localizedDescription]);
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
    NSLog(@"TUIOMessageListener: UDP socket closed");
}


@end
