//
//  ControlsTouchLayer.h
//  iReacTIVision
//
//  Created by Markus Konrad on 26.03.12.
//  Copyright (c) 2012 mkonrad.net. Licensed under GPL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ControlsView.h"

#include "CalibrationEngine.h"
#include "CalibrationGrid.h"

@class ControlsView;

@interface ControlsTouchLayer : UIView {
    CalibrationEngine *calibrator;
    CalibrationGrid *grid;
    
    int gridW;
    int gridH;
    
    BOOL gridPointSelected;
    CGPoint selectedGridPoint;
}

@property (nonatomic,assign) ControlsView *controlsView;

@end
