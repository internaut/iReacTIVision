//
//  ControlsTouchLayer.m
//  iReacTIVision
//
//  Created by Markus Konrad on 26.03.12.
//  Copyright (c) 2012 mkonrad.net. Licensed under GPL. All rights reserved.
//

#import "ControlsTouchLayer.h"

static const float kMaxTouchDistance = 50.0f;

@interface ControlsTouchLayer()
-(void)doubleTapAction:(UIGestureRecognizer *)sender;
-(CGPoint)convertGridPoint:(CGPoint)g offset:(CGPoint)o;
-(float)distBetweenPoint1:(CGPoint)p1 point2:(CGPoint)p2;
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

#pragma mark custom setter/getter

-(void)setControlsView:(ControlsView *)c {
    calibrator = c.core.calibrator;
    grid = calibrator->getGrid();
    gridW = grid->GetWidth();
    gridH = grid->GetHeight();
    
    NSLog(@"ControlsTouchLayer: Grid size is %dx%d", grid->GetWidth(), grid->GetHeight());
}

#pragma mark touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *uiTouch = [touches anyObject];
    CGPoint t = [uiTouch locationInView:self];
    
    for (int y = 0; y < gridH; y++) {
        for (int x = 0; x < gridW; x++) {
            GridPoint g = grid->Get(x, y);
            
            CGPoint p = [self convertGridPoint:CGPointMake(x, y) offset:CGPointMake(g.x, g.y)];
            
            float d = [self distBetweenPoint1:t point2:p];
            
//            NSLog(@"ControlsTouchLayer: Point %d, %d is at pos %f, %f. Dist to touch %f, %f is %f", x, y, p.x, p.y, t.x, t.y, d);
            
            if (d <= kMaxTouchDistance) {
                NSLog(@"ControlsTouchLayer: Selected point %d, %d", x, y);
                
                calibrator->setActiveGridPoint(x, y);
                
                return;
            }
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

-(void)doubleTapAction:(UIGestureRecognizer *)sender {
    [controlsView stopFullscreenCalibrating];
}

#pragma mark private methods

-(CGPoint)convertGridPoint:(CGPoint)g offset:(CGPoint)o {
    CGSize screenSize = [[TUIFrontendCore shared] screenSize];

    float stepX = screenSize.width / (float)(gridW - 1);
    float stepY = screenSize.height / (float)(gridH - 1);

//    NSLog(@"step %f, %f", stepX, stepY);
    
    return CGPointMake((g.x + o.x) * stepX, (g.y + o.y) * stepY);
}

-(float)distBetweenPoint1:(CGPoint)p1 point2:(CGPoint)p2 {
    float dX = p1.x - p2.x;
    float dY = p1.y - p2.y;
    
    return sqrtf(dX * dX + dY * dY);
}

@end
