//
//  ControlsView.m
//  iReacTIVision
//
//  Created by Markus Konrad on 15.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import "ControlsView.h"

#include "iThingCamera.h"

#include <SDL.h>

static const CGRect kControlsViewMiniFrame = CGRectMake(0, 0, 1024, 50);
static const CGRect kControlsViewMaxiFrame = CGRectMake(0, 0, 1024, 200);

enum {
    kCalibMoveGridUp = 0,
};

@interface ControlsView()

-(void)createSubviews;

-(void)updateView;

-(void)simulateKeyboardHit:(SDL_Keycode)keycode;

-(UIButton *)createButton:(NSString *)title frame:(CGRect)frame action:(SEL)action parent:(UIView *)parent;
-(UIButton *)createButton:(NSString *)title frame:(CGRect)frame action:(SEL)action parent:(UIView *)parent tag:(NSInteger)tag type:(UIButtonType)type;

-(void)calibrateAction:(id)sender;
-(void)calibResetGridAction:(id)sender;
-(void)calibResetPointAction:(id)sender;
-(void)calibRevertAction:(id)sender;

-(void)calibMoveAction:(id)sender;

-(void)switchCamsAction:(id)sender;

-(void)switchDispModeAction:(id)sender;

-(void)toggleFrontendDisplayAction:(id)sender;

@end

@implementation ControlsView

@synthesize videoEngine;
@synthesize core;

#pragma mark init/dealloc

- (id)init
{
    self = [super initWithFrame:kControlsViewMaxiFrame];
    if (self) {
        viewMode = kCtrlViewModeDefault;
    
        [self setBackgroundColor:[UIColor blackColor]];
        [self setAlpha:0.75f];
                
        [self createSubviews];
    }
    return self;
}

-(void)dealloc {
    [calibView release];
    [fpsLabel release];

    [super dealloc];
}

#pragma mark public methods

-(void)updateFpsLabel:(int)fpsValue {
    [fpsLabel setText:[NSString stringWithFormat:@"%d", fpsValue]];
}

#pragma mark ui actions

-(void)calibrateAction:(id)sender {    
    [self simulateKeyboardHit:SDLK_c];
    
    // toggle view modes
    viewMode = (viewMode != kCtrlViewModeCalib) ? kCtrlViewModeCalib : kCtrlViewModeDefault;
    
    [self updateView];
}

-(void)calibResetGridAction:(id)sender {
    [self simulateKeyboardHit:SDLK_j];
}

-(void)calibResetPointAction:(id)sender {
    [self simulateKeyboardHit:SDLK_k];
}

-(void)calibRevertAction:(id)sender {
    [self simulateKeyboardHit:SDLK_l];    
}

-(void)calibMoveAction:(id)sender {
    UIButton *btn = sender;

    SDL_Keycode key = 0;
    
    switch (btn.tag) {
        case kCalibMoveGridUp:
            key = 275;
        break;

        default:
        break;
    }
    
    if (key != 0) [self simulateKeyboardHit:key];        
}

-(void)switchCamsAction:(id)sender {
    iThingCamera *camController = (iThingCamera *)videoEngine->camera_;
    AVCaptureDevicePosition curPos = camController->getCameraDevice();
    AVCaptureDevicePosition newPos = (curPos == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    camController->switchToCameraDevice(newPos);
}

-(void)switchDispModeAction:(id)sender {
    MessageListener::DisplayMode curDispMode = videoEngine->getDisplayMode();
    
    if (curDispMode == MessageListener::NO_DISPLAY) videoEngine->setDisplayMode(MessageListener::SOURCE_DISPLAY);
    else if (curDispMode == MessageListener::SOURCE_DISPLAY) videoEngine->setDisplayMode(MessageListener::DEST_DISPLAY);
    else videoEngine->setDisplayMode(MessageListener::NO_DISPLAY);
}

-(void)toggleFrontendDisplayAction:(id)sender {
    [core toggleFrontendDisplay];
}

#pragma mark other private methods

-(void)simulateKeyboardHit:(SDL_Keycode)keycode {
    // simulate keyboard hit via SDL events
    SDL_KeyboardEvent event;
    event.type = SDL_KEYDOWN;
    SDL_KeySym key;
    key.sym = keycode;
    event.keysym = key;
    
    SDL_PushEvent((SDL_Event *)&event);
}

-(void)createSubviews {
    // calibrate button
    [self createButton:@"calibrate" frame:CGRectMake(10, 10, 90, 30) action:@selector(calibrateAction:) parent:self];
    
    // calibrate view
    calibView = [[UIView alloc] initWithFrame:CGRectMake(10, 50, self.frame.size.width - 2 * 10, self.frame.size.height - 50)];
    [calibView setHidden:YES];
    [calibView setUserInteractionEnabled:YES];
    
    [self createButton:@"reset grid" frame:CGRectMake(0, 0, 90, 30) action:@selector(calibResetGridAction:) parent:calibView];
    [self createButton:@"reset point" frame:CGRectMake(0, 40, 90, 30) action:@selector(calibResetPointAction:) parent:calibView];
    [self createButton:@"revert" frame:CGRectMake(0, 80, 90, 30) action:@selector(calibRevertAction:) parent:calibView];
    
    [self createButton:@"⬆" frame:CGRectMake(100, 80, 30, 30) action:@selector(calibMoveAction:) parent:calibView tag:kCalibMoveGridUp type:UIButtonTypeCustom];
    
    [self setExclusiveTouch:NO];
    [self addSubview:calibView];
    
    // switch cams button
    [self createButton:@"switch cameras" frame:CGRectMake(110, 10, 150, 30) action:@selector(switchCamsAction:) parent:self];
    
    // switch display mode button
    [self createButton:@"switch display mode" frame:CGRectMake(270, 10, 200, 30) action:@selector(switchDispModeAction:) parent:self];
    
    // toggle frontend display button
    [self createButton:@"toggle frontend disp" frame:CGRectMake(480, 10, 200, 30) action:@selector(toggleFrontendDisplayAction:) parent:self];
    
    // fps label
#ifdef DEBUG
    const int fpsLabelW = 50;
    const int fpsLabelH = 30;
    fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - fpsLabelW - 10, 10, fpsLabelW, fpsLabelH)];
    [fpsLabel setTextColor:[UIColor whiteColor]];
    [fpsLabel setBackgroundColor:[UIColor clearColor]];
//    [fpsLabel setOpaque:NO];
    [self updateFpsLabel:0.0f];
    [self addSubview:fpsLabel];
#endif
        
    // update the view
    [self updateView];
}

-(void)updateView {
    switch (viewMode) {
        default:
        case kCtrlViewModeDefault:
            [calibView setHidden:YES];
            [self setFrame:kControlsViewMiniFrame];
        break;
        
        case kCtrlViewModeCalib:
            [self setFrame:kControlsViewMaxiFrame];
            [calibView setHidden:NO];
        break;
    }
}

-(UIButton *)createButton:(NSString *)title frame:(CGRect)frame action:(SEL)action parent:(UIView *)parent {
    return [self createButton:title frame:frame action:action parent:parent tag:0 type:UIButtonTypeRoundedRect];
}

-(UIButton *)createButton:(NSString *)title frame:(CGRect)frame action:(SEL)action parent:(UIView *)parent tag:(NSInteger)tag type:(UIButtonType)type {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setEnabled:YES];
    [btn setTag:tag];
    
    [parent addSubview:btn];
    
    return btn;
}


@end
