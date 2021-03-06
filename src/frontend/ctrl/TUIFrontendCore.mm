//
//  TUIFrontendCore.m
//  iReacTIVision
//
//  Created by Markus Konrad on 23.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import "TUIFrontendCore.h"


// this callback is called from TUIOMsgListener upon TUIO message receive
void TUIOMsgCallbackFunction(TUIOMsg *msg) {
    [[TUIFrontendCore shared] receivedTUIOMsg:msg];
}


// Declare private methods
@interface TUIFrontendCore()

// listen for TUIO messages
-(void)listen;

@end


@implementation TUIFrontendCore

@synthesize port;
@synthesize engine;
@synthesize calibrator;
@synthesize tuiObjects;
@synthesize sound;
@synthesize controlsView;
@synthesize rootView;
@synthesize rootViewCtrl;
@synthesize screenSize;
@synthesize screenCenter;

#pragma mark init/dealloc

-(id)init {
    self = [super init];
    
    if (self) {
        // initialize with defaults
        port = 3333;
        
        screenSize = [UIScreen mainScreen].bounds.size;
        if (screenSize.width < screenSize.height) {
            CGFloat h = screenSize.height;
            screenSize.height = screenSize.width;
            screenSize.width = h;
        }
        screenCenter = CGPointMake(screenSize.width / 2.0f, screenSize.height / 2.0f);
        
        // get the application root view controller and root view
        UIApplication *uiApp = [UIApplication sharedApplication];
        UIWindow *uiWin = [uiApp.windows objectAtIndex:0];
        rootViewCtrl = uiWin.rootViewController;
        rootView = rootViewCtrl.view;
        
        // create objects
        sound = [SoundUtil shared];
        tuiObjects = [[NSMutableDictionary alloc] init];
        tuiObjectObservers = [[NSMutableSet alloc] init];
        
        // create controls view overlay
#ifdef DEBUG
        controlsView = [[ControlsView alloc] init];
        [controlsView setCore:self];
#endif
        
#ifdef DEBUG        
        // add the controls view overlay
        [rootView addSubview:controlsView];
#endif
        
        // set observers
        frontendApp = [[KashrutGame alloc] init];
        [frontendApp setCore:self];
        [self addTUIObjectObserver:frontendApp];
        
        [frontendApp loadFoodAreas];
        
        // add a subview
#ifdef DEBUG
        [frontendApp displayFoodAreaOverlay];
        [rootView insertSubview:frontendApp.foodAreaOverlay belowSubview:controlsView];
#endif
    }

    return self;
}

-(void)dealloc {
    [self stop];
    
    [frontendApp release];
    
    [tuiObjects release];
    [tuiObjectObservers release];
    
    [controlsView release];
    
    // destory other singletons
    [sound destroy];

    [super dealloc];
}

#pragma mark public methods

-(void)setEngine:(PortVideoSDL *)e {
    engine = e;
    [controlsView setVideoEngine:engine];
}

-(void)start {
    // create message listener
    msgListener = new TUIOMsgListener(&TUIOMsgCallbackFunction);

    // create udp packet listener
    sock = new UdpListeningReceiveSocket(IpEndpointName(IpEndpointName::ANY_ADDRESS, port), msgListener);
    
    // run udp listening in seperate thread
    [NSThread detachNewThreadSelector:@selector(listen) toTarget:self withObject:nil];
}

-(void)stop {
    // stop listening for TUIO messages
    sock->Break();

    // memory cleanup
    
    if (msgListener) {
        delete msgListener;
        msgListener = NULL;
    }
    
    if (sock) {
        delete sock;
        sock = NULL;
    }
    
    [tuiObjects removeAllObjects];
}

-(void)toggleFrontendDisplay {
    [frontendApp toggleDisplay];
}

-(void)receivedTUIOMsg:(TUIOMsg *)msg {    
    if (msg->cmd == kTUIOMsgCmdAlive) { // check "alive" status of objects
        NSMutableSet *objToRemove = [NSMutableSet set];
        
        if (msg->data.alive.numSessIds == 0 && [tuiObjects count] > 0) {    // no more alive objects! Remove all objects we have
            [objToRemove addObjectsFromArray:[tuiObjects allKeys]];
        } else if (msg->data.alive.numSessIds > 0) {    // we have some "alive" objects there
            // check if we have new alive objects
            NSMutableSet *aliveObjects = [NSMutableSet set];    // set with NSNumber sessIds
            for (int i = 0; i < msg->data.alive.numSessIds; i++) {
                int sessId = msg->data.alive.sessIds[i];
                NSNumber *sessIdNumber = [NSNumber numberWithInt:sessId];
                
                if (![tuiObjects objectForKey:sessIdNumber]) {  // we didn't know this id yet, so we have a new one!
                    TUIObject *obj = [TUIObject objectWithSessId:sessId];
                    [tuiObjects setObject:obj forKey:sessIdNumber];
                    
                    // inform the observers
                    for (id<TUIObjectObserver> observer in tuiObjectObservers) {
                        [observer addedTUIObject:obj];
                    }
                }
                
                // add this id to the "alive ids"
                [aliveObjects addObject:sessIdNumber];
            }
            
            // check if we can kick out dead objects
            for (NSNumber *objId in [tuiObjects allKeys]) {                
                if (![aliveObjects containsObject:objId]) {
                    [objToRemove addObject:objId];
                }
            }
        }
        
        // really remove objects and inform the observers
        for (NSNumber *objId in objToRemove) {
            for (id<TUIObjectObserver> observer in tuiObjectObservers) {
                [observer removedTUIObject:[tuiObjects objectForKey:objId]];
            }
            
            [tuiObjects removeObjectForKey:objId];
        }
    } else if (msg->cmd == kTUIOMsgCmdSet) {    // update an object
        NSNumber *sessId = [NSNumber numberWithInt:msg->data.set.sessId];
        
        TUIObject *obj = [tuiObjects objectForKey:sessId];  // get the object
        
        if (obj) {
            // update the object's properties
            BOOL justInitialized = NO;
            
            if (!obj.initialized && msg->data.set.classId != 0) {
                [obj setInitialized:YES];
                justInitialized = YES;
                [obj setClassId:msg->data.set.classId];
            }

            [obj setPos:CGPointMake(msg->data.set.pos.x, msg->data.set.pos.y)];
            [obj setAngle:msg->data.set.angle];
            
            // inform the observers
            for (id<TUIObjectObserver> observer in tuiObjectObservers) {
                [observer updatedTUIObject:obj
                               velocityVec:CGPointMake(msg->data.set.vel.x, msg->data.set.vel.y)
                          rotationVelocity:msg->data.set.angleVel
                               motionAccel:msg->data.set.motAccel
                             rotationAccel:msg->data.set.rotAccel
                           justInitialized:justInitialized];
            }
        }
    }
    
    delete msg;
}

-(void)addTUIObjectObserver:(id<TUIObjectObserver>)observer {
    [tuiObjectObservers addObject:observer];
}

-(void)removeTUIObjectObserver:(id<TUIObjectObserver>)observer {
    [tuiObjectObservers removeObject:observer];
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
