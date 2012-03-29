//
//  ControlsTouchLayer.m
//  iReacTIVision
//
//  Created by Markus Konrad on 26.03.12.
//  Copyright (c) 2012 mkonrad.net. Licensed under GPL. All rights reserved.
//

#import "ControlsTouchLayer.h"


@interface ControlsTouchLayer()
-(void)doubleTapAction:(UIGestureRecognizer *)sender;
@end

@implementation ControlsTouchLayer

@synthesize controlsView;

#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:YES];
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];
        
        UITapGestureRecognizer *dblTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        [dblTapRecognizer setNumberOfTapsRequired:2];
        [self addGestureRecognizer:dblTapRecognizer];
        [dblTapRecognizer release];

    }
    
    return self;
}

-(void)dealloc {

    [super dealloc];
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch!");
    
    [super touchesBegan:touches withEvent:event];
}

-(void)doubleTapAction:(UIGestureRecognizer *)sender {
    [controlsView stopFullscreenCalibrating];
}

@end
