//
//  ControlsView.h
//  iReacTIVision
//
//  Created by Markus Konrad on 15.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import <UIKit/UIKit.h>

#import "TUIFrontendCore.h"

#include "PortVideoSDL.h"

typedef enum {
    kCtrlViewModeDefault = 0,
    kCtrlViewModeCalib
} ctrlViewMode;

@class TUIFrontendCore;

@interface ControlsView : UIView {
    ctrlViewMode viewMode;
    UIView *calibView;
    UILabel *fpsLabel;
}

@property (nonatomic,assign) PortVideoSDL *videoEngine;
@property (nonatomic,assign) TUIFrontendCore *core;

-(void)updateFpsLabel:(int)fpsValue;

@end
