//
//  ControlsView.m
//  iReacTIVision
//
//  Created by Markus Konrad on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ControlsView.h"

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

@end

@implementation ControlsView

@synthesize videoEngine;

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

    [super dealloc];
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
