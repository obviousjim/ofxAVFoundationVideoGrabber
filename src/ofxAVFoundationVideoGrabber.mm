/*
 *  untitled.cpp
 *  ofxAVFoundationVideoGrabberExample
 *
 *  Created by Jim on 2/22/12.
 *  Copyright 2012 FlightPhase. All rights reserved.
 *
 */

#include "ofxAVFoundationVideoGrabber.h"
#import "AVFoundationVideoRecorder.h"

#pragma mark delegate

@interface ofxAVFoundationVideoRecorderDelegate : NSObject<AVFoundationVideoGrabberDelegate> {
 
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;	// This method is always called on the main thread.
- (void)pixelBufferReadyForProcessing:(CVPixelBufferRef)pixelBuffer;	// This method is always called on the main thread.
- (void)recordingWillStart;
- (void)recordingDidStart;
- (void)recordingWillStop;
- (void)recordingDidStop;    

@property(nonatomic, assign) ofxAVFoundationVideoGrabber* grabberDelegate;

@end

@implementation ofxAVFoundationVideoRecorderDelegate
@synthesize grabberDelegate;

- (void)pixelBufferReadyForProcessing:(CVPixelBufferRef)pixelBuffer
{
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
	int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    unsigned char *uv = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    grabberDelegate->updatePixels(pixel, uv, bufferWidth, bufferHeight);

	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );	
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );

    int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
	int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
	unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    unsigned char *uv = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);

    grabberDelegate->updateTexture(pixel, uv, bufferWidth, bufferHeight);
	
//    if(!grabberDelegate->testuv.bAllocated()){
//        grabberDelegate->testuv.allocate(bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA);   
//    }
//    cout << "uploading texture " << endl;
    //grabberDelegate->testuv.loadData((unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1), 640, 240, GL_LUMINANCE);
    
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
}

- (void)recordingWillStart
{
	
}

- (void)recordingDidStart
{
    
}

- (void)recordingWillStop
{
    
}

- (void)recordingDidStop
{
    
}

@end

#pragma mark cpp

ofxAVFoundationVideoGrabber::ofxAVFoundationVideoGrabber(){
	grabber = nil;
    pixelFormat = OF_PIXELS_RGB;
    bFrameIsNew = false;
    bUseTexture = true;
    bUsePixels = true;
}

ofxAVFoundationVideoGrabber::~ofxAVFoundationVideoGrabber(){

}

void ofxAVFoundationVideoGrabber::setPixelFormat(ofPixelFormat newPixelFormat){
    if(pixelFormat != newPixelFormat && (newPixelFormat == OF_PIXELS_RGB || newPixelFormat == OF_PIXELS_MONO) ){
    	pixelFormat = newPixelFormat;
        allocateMemory();
    }
}

ofPixelFormat ofxAVFoundationVideoGrabber::getPixelFormat(){
	return pixelFormat;
}

void ofxAVFoundationVideoGrabber::update(){

}

bool ofxAVFoundationVideoGrabber::initGrabber(int w, int h){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    if(grabber != nil){
    	[grabber release];
        [delegate release];
    }
    
    width  = w;
    height = h;

    allocateMemory();

    grabber = [[AVFoundationVideoRecorder alloc] init];
    delegate = [[ofxAVFoundationVideoRecorderDelegate alloc] init];
    delegate.grabberDelegate = this;
    grabber.delegate = delegate;

    [grabber setupAndStartCaptureSessionWithWidth:width andHeight:height];
    
    [pool drain];
    
    return true;
}

void ofxAVFoundationVideoGrabber::setUseTexture(bool useTexture){
	if(bUseTexture != useTexture){
    	bUseTexture = useTexture;
        allocateMemory();
    }
}

void ofxAVFoundationVideoGrabber::setUsePixels(bool usePixels){
	if(bUsePixels != usePixels){
    	bUsePixels = usePixels;
        allocateMemory();
    }
}

//called back from the video grabber, but on the main thread
void ofxAVFoundationVideoGrabber::updatePixels(unsigned char* pix, unsigned char* uv, int bufferWidth, int bufferHeight){
    if(!bUsePixels){
    	return;
    }
    
    if(bufferWidth != width || bufferHeight != height){
        ofLog(OF_LOG_WARNING, "Forcing texture size from %dx%d to %dx%d", width,height, bufferWidth,bufferHeight);
        width = bufferWidth;
        height = bufferHeight;
        allocateMemory();
    }
    
    bFrameIsNew = true;
    if(pixelFormat == OF_PIXELS_MONO){
        memcpy(pixels.getPixels(), pix, sizeof(unsigned char) * bufferWidth * bufferHeight);
    }
    else if(pixelFormat == OF_PIXELS_RGB){
//		unsigned char* pix = pixels.getPixels();
//        for(int y = 0; y < height; y++){
//	        for(int x = 0; x < width; x++){
//            	
//            }
//        }
    }    
}

void ofxAVFoundationVideoGrabber::updateTexture(unsigned char* pix,unsigned char* uv, int bufferWidth, int bufferHeight){
    if(!bUseTexture){
		return;    
    }
    
	if(bufferWidth != width || bufferHeight != height){
        ofLog(OF_LOG_WARNING, "Forcing texture size from %dx%d to %dx%d", width,height, bufferWidth,bufferHeight);
        width = bufferWidth;
        height = bufferHeight;
        allocateMemory();
    }

    if(bUsePixels){
        //use our processed pixels instead of those provided
		pix = pixels.getPixels();
    }
    
    bFrameIsNew = true;
    if(pixelFormat == OF_PIXELS_MONO){
        texture.loadData(pix, width, height, GL_LUMINANCE);
    }
    else if(pixelFormat == OF_PIXELS_RGB){
        texture.loadData(pix, width, height, GL_RGB);
    }
}

void ofxAVFoundationVideoGrabber::allocateMemory(){
    if(bUseTexture){
        if (pixelFormat == OF_PIXELS_RGB) {
            texture.allocate(width, height, GL_RGB);
        }
        else if(pixelFormat == OF_PIXELS_MONO){
            texture.allocate(width, height, GL_LUMINANCE);
        }
    }
    
    if(bUsePixels){
        if (pixelFormat == OF_PIXELS_RGB) {
            pixels.allocate(width, height, OF_PIXELS_RGB);
        }
        else if(pixelFormat == OF_PIXELS_MONO){
            pixels.allocate(width, height, OF_PIXELS_MONO);        	
        }
    }
}

bool ofxAVFoundationVideoGrabber::isFrameNew(){	
    bool ret = bFrameIsNew;
    bFrameIsNew = false;
    return ret;
}

void ofxAVFoundationVideoGrabber::draw(float x, float y, float w, float h){
 	draw(ofRectangle(x,y,w,h));	
}

void ofxAVFoundationVideoGrabber::draw(float x, float y){
 	draw(ofRectangle(x,y,width,height));	
}

void ofxAVFoundationVideoGrabber::draw(ofRectangle rect){
	if(bUseTexture){
        texture.draw(rect);
    }
}

float ofxAVFoundationVideoGrabber::getWidth(){ 
    return width;
}

float ofxAVFoundationVideoGrabber::getHeight(){
    return height;
}

unsigned char* ofxAVFoundationVideoGrabber::getPixels(){
    if(!bUsePixels){
    	ofLogWarning("ofxAVFoundationVideoGrabber -- getPixels not using pixels.");
    }
    return pixels.getPixels();
}

ofPixelsRef ofxAVFoundationVideoGrabber::getPixelsRef(){
    if(!bUsePixels){
    	ofLogWarning("ofxAVFoundationVideoGrabber -- getPixelsRef not using pixels.");
    }
    return pixels;
}

ofTexture& ofxAVFoundationVideoGrabber::getTextureReference(){
	return texture;
}

void ofxAVFoundationVideoGrabber::setVerbose(bool bTalkToMe){
	bVerbose = bTalkToMe;
}

void ofxAVFoundationVideoGrabber::setDeviceID(int _deviceID){
	//TODO: should use something like this to front/back facing camera	
}

void ofxAVFoundationVideoGrabber::setDesiredFrameRate(int framerate){
    
}

void ofxAVFoundationVideoGrabber::videoSettings(){
	ofLogWarning("ofxAVFoundationVideoGrabber -- Video Settings not implemented");
}

void ofxAVFoundationVideoGrabber::listDevices(){
	ofLogWarning("ofxAVFoundationVideoGrabber -- List Devices not implemented");	
}

void ofxAVFoundationVideoGrabber::close(){
    if(grabber != NULL){
        
		[grabber stopAndTearDownCaptureSession];
        [grabber release];
        [delegate release];
    }
}
