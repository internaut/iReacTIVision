//
//  iThingCamera.h
//  iReacTIVision
//
//  Created by Markus Konrad on 25.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#ifndef ITHINGCAMERA_H
#define ITHINGCAMERA_H

#import <AVFoundation/AVFoundation.h>

#include "../common/cameraEngine.h"
#include "iThingCamHelper.h"

//#include <unistd.h>
//	#define hibyte(x) (unsigned char)((x)>>8)
	
class iThingCamera : public CameraEngine
{
public:
	iThingCamera(const char* config_file);
	iThingCamera();
    ~iThingCamera();
	
	bool findCamera();
	bool initCamera();
	bool startCamera();
	unsigned char* getFrame();
	bool stopCamera();
	bool stillRunning();
	bool resetCamera();
	bool closeCamera();

	int getCameraSettingStep(int mode) { return 0; }
	bool setCameraSettingAuto(int mode, bool flag) { return false; }
	bool setCameraSetting(int mode, int value) { return false; }
	int getCameraSetting(int mode) { return 0; }
	int getMaxCameraSetting(int mode) { return 0; }
	int getMinCameraSetting(int mode) { return 0; }
		
	void showSettingsDialog();
	void drawGUI(SDL_Surface *display) {};
	
    void switchToCameraDevice(AVCaptureDevicePosition dev);
    AVCaptureDevicePosition getCameraDevice();
    
private:
    iThingCamState *camState;
};

#endif
