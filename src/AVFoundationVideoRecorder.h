//
//  AVFoundationVideoGrabber.h
//  ofxAVFoundationVideoGrabberExample
//
//  Created by Jim on 2/22/12.
//  Copyright 2012 FlightPhase. All rights reserved.
//

#ifndef TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>

@protocol AVFoundationVideoGrabberDelegate;

@interface AVFoundationVideoRecorder : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
	NSMutableArray *previousSecondTimestamps;
	Float64 videoFrameRate;
	CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;
	
	AVCaptureSession *captureSession;
	AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
	CMBufferQueueRef previewBufferQueue;
	
	NSURL *movieURL;
	AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterAudioIn;
	AVAssetWriterInput *assetWriterVideoIn;
	dispatch_queue_t movieWritingQueue;
    
	AVCaptureVideoOrientation referenceOrientation;
	AVCaptureVideoOrientation videoOrientation;
    
	// Only accessed on movie writing queue
    BOOL readyToRecordAudio; 
    BOOL readyToRecordVideo;
	BOOL recordingWillBeStarted;
	BOOL recordingWillBeStopped;
	
	BOOL recording;
}

@property (readonly) Float64 videoFrameRate;
@property (readonly) CMVideoDimensions videoDimensions;
@property (readonly) CMVideoCodecType videoType;

@property (readwrite) AVCaptureVideoOrientation referenceOrientation;

@property (readwrite, assign) id<AVFoundationVideoGrabberDelegate> delegate;

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation;

- (void) showError:(NSError*)error;

- (BOOL) setupCaptureSessionWithWidth:(NSInteger)width andHeight:(NSInteger) height;
- (void) setupAndStartCaptureSessionWithWidth:(NSInteger) width andHeight:(NSInteger) height;

- (void) stopAndTearDownCaptureSession;

- (void) startRecording;
- (void) stopRecording;

- (void) pauseCaptureSession; // Pausing while a recording is in progress will cause the recording to be stopped and saved.
- (void) resumeCaptureSession;

@property(readonly, getter=isRecording) BOOL recording;

@end

@protocol AVFoundationVideoGrabberDelegate<NSObject>
@required
- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;		// This method is always called on the main thread.
- (void)pixelBufferReadyForProcessing:(CVPixelBufferRef)pixelBuffer;	// This method is always called on the main thread.
- (void)recordingWillStart;
- (void)recordingDidStart;
- (void)recordingWillStop;
- (void)recordingDidStop;
@end

          
