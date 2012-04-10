/*
 *  ofxAVFoundationVideoGrabber.h
 *  ofxAVFoundationVideoGrabberExample
 *
 *  Created by Jim on 2/22/12.
 *
 */
#pragma once
#include "ofMain.h"

#ifdef __OBJC__
@class AVFoundationVideoRecorder;
@class ofxAVFoundationVideoRecorderDelegate;
#endif

class ofxAVFoundationVideoGrabber  : public ofBaseVideoGrabber {
  public:
    ofxAVFoundationVideoGrabber();
    ~ofxAVFoundationVideoGrabber();
    
    //needs implementing
    void listDevices();
    bool initGrabber(int w, int h);
    void update();
    bool isFrameNew();
    
    void setUseTexture(bool useTexture);
    void setUsePixels(bool usePixels);
    
    unsigned char* getPixels();
    
    void draw(float x, float y);    
    void draw(float x, float y, float w, float h);
    void draw(ofRectangle rect);
    
    void close();
    
    float getHeight();
    float getWidth();
    
    //should implement!
    void setVerbose(bool bTalkToMe);
    void setDeviceID(int _deviceID);
    void setDesiredFrameRate(int framerate);
    void videoSettings();
    void setPixelFormat(ofPixelFormat pixelFormat);
    ofPixelFormat getPixelFormat();

    ofPixelsRef getPixelsRef();
    ofTexture& getTextureReference();

    //called internally by the objective c process
    void updatePixels(unsigned char* pix, unsigned char* uv, int width, int height);
    void updateTexture(unsigned char* pix, unsigned char* uv, int width, int height);
	ofTexture testuv;
    
  protected:
    int width;
    int height;
    
    //ofShader yuvcombine;
    
    void allocateMemory();
    
    ofPixelFormat pixelFormat;
    ofPixels pixels;
    ofTexture texture;

    
    bool bFrameIsNew;
    bool bVerbose;    
    bool bUseAudio;
    bool bUseTexture;
    bool bUsePixels;
    
	#ifdef __OBJC__
    AVFoundationVideoRecorder* grabber; //only obj-c needs to know the type of this protected var
    ofxAVFoundationVideoRecorderDelegate* delegate;
	#else
    void* grabber;
    void* grabberDelegate
	#endif
};
