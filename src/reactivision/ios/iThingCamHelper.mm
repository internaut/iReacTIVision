//
//  iThingCamHelper.m
//  reacTIViOS
//
//  Created by Markus Konrad on 11.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iThingCamHelper.h"

#import "Tools.h"


iThingCamState *iThingCamNew() {
    iThingCamState *pState = NULL;
    pState = (iThingCamState *)malloc(sizeof(iThingCamState));
    return pState;
}

OSErr iThingCamInit(iThingCamState *pState, AVCaptureDevicePosition devicePos) {
    OSErr err = 0;

	// zero initialize the structure
	memset(pState, 0, sizeof(iThingCamState));
    
    // set fps
    pState->captureRate = 30;
    
    // Create our capture session
    pState->session = [[AVCaptureSession alloc] init];
    if (!pState->session) return 1;
    
    [pState->session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // Find the camera and set it as input
    pState->camPositionUnknown = 1;
    pState->captureInput = NULL;
    
    iThingCamChangeDevice(pState, devicePos);
    
    // Create the video preview layer
    pState->videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:pState->session];
    [pState->videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [pState->videoLayer setOrientation:AVCaptureVideoOrientationPortrait];
    
//    // Setup layer size to fullscreen and add it to our context
//    [pState->videoLayer setFrame:[self bounds]];
//    [[self layer] addSublayer:_videoLayer];

    // Add the single frame grabber
    pState->grabber = [[AVCaptureVideoDataOutput alloc] init];
    [pState->grabber setAlwaysDiscardsLateVideoFrames:YES];
    [pState->grabber setMinFrameDuration:CMTimeMake(1, 60)];

    // create sample buffer delegate
    pState->sampleBufferDelegate = [[iThingCamSampleBufferDelegate alloc] init];
    [(iThingCamSampleBufferDelegate *)pState->sampleBufferDelegate setCamState:pState];

    // Create a serial queue to handle the processing of our frames
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[pState->grabber setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)pState->sampleBufferDelegate queue:queue];
	dispatch_release(queue);
    
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[pState->grabber setVideoSettings:videoSettings]; 
    
    [pState->session addOutput:pState->grabber];
    
    return err;
}

OSErr iThingCamChangeDevice(iThingCamState *pState, AVCaptureDevicePosition devicePos) {
    if (pState->camPositionUnknown != 1 && pState->camPosition == devicePos) return 0; // no change
    
    // pause the av session
    bool wasRunning = iThingCamIsGrabbing(pState);
    iThingCamStopGrabbing(pState);
    
    // get the right camera
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *camera = nil;
    
    for (AVCaptureDevice* device in videoDevices) {
        if (device.position == devicePos) {
            camera = device;
            break;
        }
    }
    
    if (camera == nil) return 2;    // could not find a cam with that position!
    
    // set the new state
    pState->camPosition = devicePos;
    
    // If we setup the session, we also are responsible to setup the
    // video device (default camera device) for image capture
    NSError* error = nil;  
    [camera lockForConfiguration:&error];
    [camera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    [camera unlockForConfiguration];

    // Remove previous AVCaptureInput if neccessary
    if (pState->captureInput) {
        [pState->session removeInput:pState->captureInput];
        [pState->captureInput release];
    }

    // Create a new AVCaptureInput with the camera device
    pState->captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];  

    // add it to the session
    [pState->session addInput:pState->captureInput];
    
    // set new status
    pState->camPositionUnknown = 0;
    
    // start the session again
    if (wasRunning) iThingCamStartGrabbing(pState);
    
    return 0;
}

bool iThingCamIsGrabbing(iThingCamState *pState) {
    return pState->session.isRunning;
}

OSErr iThingCamStartGrabbing(iThingCamState *pState) {
    if (iThingCamIsGrabbing(pState)) return 0;

    [pState->session startRunning];
    
    return 0;
}

OSErr iThingCamStopGrabbing(iThingCamState *pState) {
    if (!iThingCamIsGrabbing(pState)) return 0;

    [pState->session stopRunning];
    
    return 0;
}

void iThingCamDelete(iThingCamState *pState) {
    [pState->session release];
    [pState->videoLayer release];
    [pState->grabber release];
    [(NSObject *)pState->sampleBufferDelegate release];
    
    free(pState);
    pState = NULL;
}

void iThingCamGetFrame(iThingCamState *pState, unsigned char **buf) {
    // clear old buffer
    if (buf != NULL && *buf != NULL) {
        free(*buf);
        *buf = NULL;
    }
        
    if (!iThingCamIsGrabbing(pState) || pState->buffer == NULL) {
        return;
    }
    
    // wait until unlocked
    while (pState->bufLocked) usleep(100);
    
    // lock for us and copy data
    pState->bufLocked = 1;
    *buf = (unsigned char *)malloc(sizeof(unsigned char) * pState->bufLength);
    memcpy(*buf, pState->buffer, pState->bufLength);
    pState->bufLocked = 0;
}


@implementation iThingCamSampleBufferDelegate 

@synthesize camState;

- (id)init {
    self = [super init];
    if (self) {
        writtenFrames = 0;
    }
    return self;
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate messages

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

	// Check if we need to capture
    if ([[NSDate date] timeIntervalSince1970] < camState->lastCapture + 1.0f / camState->captureRate) {
//        NSLog(@"too early!");
        return;
    }
        
    // Since we are no longer in the main thread the main autorelease pool isn't addressed by our locally created objects
    // So we have the create an autorelease pool ourselves
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    // Extract the image from the video sample buffer
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the image buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0); 
    
    // Get information about the image
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer);  
    
    // Build an image from the data
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB(); 
    CGContextRef rgbContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, rgbColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef rgbImage = CGBitmapContextCreateImage(rgbContext); 
    
//    UIImage *rgbUIImage = [UIImage imageWithCGImage:rgbImage];
//    [Tools saveImage:rgbUIImage maxCount:10];
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(rgbContext);

    // wait until unlocked
    while (camState->bufLocked) usleep(100);
    
    // lock buffer
    camState->bufLocked = 1;
    
    // clear buffer
//    if (camState->buffer != NULL) {
//        free(camState->buffer);
//        camState->buffer = NULL;
//    }

    // allocate buffer for greyscale image
    if (camState->buffer == NULL) {
#if (kUsePortrait == 0)
        camState->pixelsWidth = kScreenW; 
        camState->pixelsHeight = kScreenH;
#else
        camState->pixelsWidth = kScreenH; 
        camState->pixelsHeight = kScreenW;
#endif

        camState->bufLength = camState->pixelsWidth * camState->pixelsHeight;
        camState->buffer = (unsigned char *)malloc(sizeof(unsigned char) * camState->bufLength);
    }
    
    // make grayscale
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef grayContext = CGBitmapContextCreate(camState->buffer, camState->pixelsWidth, camState->pixelsHeight, 8, camState->pixelsWidth, grayColorSpace, kCGImageAlphaNone);
    
    // We will also have to flip the y axis if we have the front cam!
    if (camState->camPosition == AVCaptureDevicePositionFront) {
        CGPoint ctr = CGPointMake(camState->pixelsWidth / 2.0f, camState->pixelsHeight / 2.0f);
        CGContextTranslateCTM(grayContext, ctr.x, ctr.y);
        CGContextScaleCTM(grayContext, 1.0f, -1.0f);
        CGContextTranslateCTM(grayContext, -ctr.x, -ctr.y);
    }
    
    // Draw the image in the context
    CGContextDrawImage(grayContext, CGRectMake(0, 0, camState->pixelsWidth, camState->pixelsHeight), rgbImage);
    
//    [Tools saveBuffer:camState->buffer width:camState->pixelsWidth height:camState->pixelsHeight channels:1 maxCount:10];
    
    // unlock buffer
    camState->bufLocked = 0;
    
    // release data
    CGContextRelease(grayContext);
    CGColorSpaceRelease(grayColorSpace);
    CGImageRelease(rgbImage);
            	
	// We unlock the image buffer
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // update last capture time
	camState->lastCapture = [[NSDate date] timeIntervalSince1970];
    
    // Autorelease all required objects
	[pool drain];

}

@end