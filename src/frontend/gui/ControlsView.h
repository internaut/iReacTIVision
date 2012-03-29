//
//  ControlsView.h
//  iReacTIVision
//
//  Created by Markus Konrad on 15.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import <UIKit/UIKit.h>

#import "TUIFrontendCore.h"
#import "ControlsTouchLayer.h"

#include "PortVideoSDL.h"

typedef enum {
    kCtrlViewModeDefault = 0,
    kCtrlViewModeCalib,
    kCtrlViewModeCalibFullscreen,
} ctrlViewMode;

@class TUIFrontendCore;
@class ControlsTouchLayer;

@interface ControlsView : UIView {
    ctrlViewMode viewMode;
    UIView *calibView;
    UILabel *fpsLabel;
    
    ControlsTouchLayer *touchLayer;
}

@property (nonatomic,assign) PortVideoSDL *videoEngine;
@property (nonatomic,assign) TUIFrontendCore *core;

-(void)updateFpsLabel:(int)fpsValue;

-(void)stopFullscreenCalibrating;

@end
