//
//  AudioController.h
//  iReacTIVision
//
//  Created by Markus Konrad on 24.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TUIFrontendCore.h"
#import "TUIObjectObserver.h"

@interface AudioController : NSObject <TUIObjectObserver> {

}

@property (nonatomic,assign) TUIFrontendCore *core;

@end
