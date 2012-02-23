//
//  TUIFrontendCore.m
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIFrontendCore.h"

@interface TUIFrontendCore()
-(void)listen;
@end

@implementation TUIFrontendCore

@synthesize port;

#pragma mark init/dealloc

-(id)init {
    self = [super init];
    
    if (self) {
        port = 3333;
    }

    return self;
}

-(void)dealloc {
    [self stop];

    [super dealloc];
}

#pragma mark public methods

-(void)start {
    // create message listener
    msgListener = new TUIOMsgListener(NULL);

    // create udp packet listener
    sock = new UdpListeningReceiveSocket(IpEndpointName(IpEndpointName::ANY_ADDRESS, port), msgListener);
    
    // run udp listening in seperate thread
    [NSThread detachNewThreadSelector:@selector(listen) toTarget:self withObject:nil];
}

-(void)stop {
    sock->Break();

    if (msgListener) delete msgListener;
    if (sock) delete sock;
}

#pragma mark private methods

-(void)listen {
    sock->Run();
}

#pragma mark singleton stuff

static TUIFrontendCore *sharedObject;

+ (TUIFrontendCore *)shared {
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;    
}

- (void)destroy {
    [sharedObject dealloc];
    sharedObject = nil;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self shared] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
