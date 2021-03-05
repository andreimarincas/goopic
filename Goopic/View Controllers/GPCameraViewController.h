//
//  GPCameraViewController.h
//  Goopic
//
//  Created by andrei.marincas on 29/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPBaseViewController.h"
#import "GPCameraViewToolbar.h"


@class CIDetector;


@interface GPCameraView : UIView

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoLayer;

// Designated initializer
- (instancetype)init;

@end


@interface GPCameraViewController : GPBaseViewController <UIGestureRecognizerDelegate,
                                                          AVCaptureVideoDataOutputSampleBufferDelegate,
                                                          GPCameraViewToolbarDelegate>
{
//	UIView *flashView;
    
//    id _videoBox; // CGRect
    
    UIImage *_blurImage;
    UIDeviceOrientation _blurImageOrientation;
    UIDeviceOrientation _deviceOrientation;
}

// Session management

// Camera session
@property (nonatomic, strong) AVCaptureSession * session;

@property (nonatomic, strong) AVCaptureDeviceInput * cameraDeviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput * stillImageOutput;

// Communicate with the session and other session objects on this queue
@property (nonatomic, strong) dispatch_queue_t sessionQueue;


// Video Session
@property (nonatomic, strong) AVCaptureSession * videoSession;

@property (nonatomic, strong) AVCaptureDeviceInput * videoDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoSessionQueue;

// Process video frames in this queue
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;


// Utilities
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;

@property (nonatomic) id videoRuntimeErrorHandlingObserver;

// Interface
@property (nonatomic, strong) GPCameraView *cameraView;

// Blur
@property (nonatomic, strong) CALayer *blurLayer;
//@property (nonatomic, strong) UIImageView *blurView;
@property (nonatomic, readonly) BOOL hasCameraBlur;

// Toolbars
@property (nonatomic, strong) GPCameraViewTopToolbar *topToolbar;
@property (nonatomic, strong) GPCameraViewBottomToolbar *bottomToolbar;

// Designated initializer
- (instancetype)init;

@end
