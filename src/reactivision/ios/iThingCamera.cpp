//
//  iThingCamera.cpp
//  iReacTIVision
//
//  Created by Markus Konrad on 25.02.12.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#include "iThingCamera.h"

iThingCamera::iThingCamera(const char* cfg):CameraEngine(cfg)
{
	cameraID = -1;
	
	buffer = NULL;
    
    sprintf(cameraName,"iThingCamera");
	
	running=false;
	lost_frames=0;
	
//	dstPort = NULL;
//	vdImageDesc = NULL;
	camState = NULL;
	
	timeout = 5000;
}

iThingCamera::iThingCamera():CameraEngine(NULL)
{
	iThingCamera(NULL);
}

iThingCamera::~iThingCamera()
{
	if (buffer!=NULL) delete []buffer;
}

void iThingCamera::switchToCameraDevice(AVCaptureDevicePosition dev) {
    iThingCamChangeDevice(camState, dev);
}

AVCaptureDevicePosition iThingCamera::getCameraDevice() {
    return camState->camPosition;
}

bool iThingCamera::findCamera() {

	OSErr err;
	
	if(!(camState = iThingCamNew()))
	{
		printf("iThingCamera: failed to allocate\n");
		return false;
	}
    
	if((err = iThingCamInit(camState, kInitialCamPosition)))
	{
		printf("iThingCamera: no camera found\n");
		return false;
	}

	cameraID = 0;
	return true;
}

bool iThingCamera::initCamera() {

	if (cameraID < 0) return false;
	readSettings();

//	OSErr err;
    
    // hardcoded until now...
    // this is for the back cam. front has 640x480
    this->width = kScreenW;
    this->height = kScreenH;

    fps = camState->captureRate;

	return true;
}

unsigned char* iThingCamera::getFrame()
{    
    iThingCamGetFrame(camState, &buffer);
    
    return buffer;	
}

bool iThingCamera::startCamera()
{
	OSErr err;
	if ((err = iThingCamStartGrabbing(camState)))
	{
		printf("could not start camera\n");
		return false;
	}

	running = true;
	return true;
}

bool iThingCamera::stopCamera()
{
	running=false;

	OSErr err;
	if ((err = iThingCamStopGrabbing(camState)))
	{
		printf("errors while stopping camera\n");
		return false;
	}

	return true;
}

bool iThingCamera::stillRunning() {
	return running;
}

bool iThingCamera::resetCamera()
{
  return (stopCamera() && startCamera());
}

bool iThingCamera::closeCamera() {
	if (camState) {
		iThingCamDelete(camState);
		camState = NULL;
	}	

	return true;
}

void iThingCamera::showSettingsDialog() {
    // not implemented
}

