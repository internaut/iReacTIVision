//
//  ControlsView.h
//  iReacTIVision
//
//  Created by Markus Konrad on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "PortVideoSDL.h"

typedef enum {
    kCtrlViewModeDefault = 0,
    kCtrlViewModeCalib
} ctrlViewMode;

@interface ControlsView : UIView {
    ctrlViewMode viewMode;
    UIView *calibView;
    UILabel *fpsLabel;
}

@property (nonatomic,assign) PortVideoSDL *videoEngine;

-(void)updateFpsLabel:(int)fpsValue;

@end
