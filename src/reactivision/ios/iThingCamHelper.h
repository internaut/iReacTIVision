//
//  iThingCamHelper.h
//  reacTIViOS
//
//  Created by Markus Konrad on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#ifndef ITHINGCAMHELPER_H
#define ITHINGCAMHELPER_H


//typedef struct tagiThingCamState iThingCamState;

struct iThingCamState {
    int camPositionUnknown; // is "1" if not yet initialized
    AVCaptureDevicePosition camPosition;    // front or back for iPad2
    
    AVCaptureInput *captureInput;   // current video input device

    AVCaptureSession *session;  // current capturing session
    
    AVCaptureVideoPreviewLayer *videoLayer;    // video preview layer
    
    AVCaptureVideoDataOutput *grabber; // image grabber
    NSTimeInterval lastCapture;
    float captureRate;    // in frames per second
    
    void *sampleBufferDelegate; // object that implements AVCaptureVideoDataOutputSampleBufferDelegate
    
    bool bufLocked;
    unsigned char *buffer;      // image data buffer
    unsigned long bufLength;    // image data buffer length
    
    int pixelsWidth;
    int pixelsHeight;
};

iThingCamState *iThingCamNew();

OSErr iThingCamInit(iThingCamState *pState, AVCaptureDevicePosition devicePos);

//OSErr iThingCamGetImageDescription(iThingCamState *pState, ImageDescriptionHandle vdImageDesc);

bool iThingCamIsGrabbing(iThingCamState *pState);

OSErr iThingCamChangeDevice(iThingCamState *pState, AVCaptureDevicePosition devicePos);

OSErr iThingCamStartGrabbing(iThingCamState *pState);

OSErr iThingCamStopGrabbing(iThingCamState *pState);

void iThingCamDelete(iThingCamState *pState);

void iThingCamGetFrame(iThingCamState *pState, unsigned char **buf);


//struct bmpfile_magic {
//  unsigned char magic[2];
//};
// 
//struct bmpfile_header {
//  uint32_t filesz;
//  uint16_t creator1;
//  uint16_t creator2;
//  uint32_t bmp_offset;
//};

@interface iThingCamSampleBufferDelegate : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
    int writtenFrames;
}

@property (nonatomic,assign) iThingCamState *camState;

@end

#endif