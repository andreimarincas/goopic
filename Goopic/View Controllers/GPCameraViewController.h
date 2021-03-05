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


#pragma mark - Camera View

@interface GPCameraView : UIView

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoLayer;

// Designated initializer
- (instancetype)init;

@end


#pragma mark - Camera View Controller

@interface GPCameraViewController : GPBaseViewController <UIGestureRecognizerDelegate,
                                                          AVCaptureVideoDataOutputSampleBufferDelegate,
                                                          GPCameraViewToolbarDelegate>
{
    UIDeviceOrientation _deviceOrientation;
    
    BOOL _cameraRunning;
    BOOL _capturingStillImage;
    
    UIImage *_capturedImage;
    id _imageMetadata;
    
    BOOL _canUpdateButtons;
}

// Session management

// Camera session
@property (nonatomic, strong) AVCaptureSession * session;

@property (nonatomic, strong) AVCaptureDeviceInput * cameraDeviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput * stillImageOutput;

// Communicate with the session and other session objects on this queue
@property (nonatomic, strong) dispatch_queue_t sessionQueue;


#if (CAMERA_BLUR_ENABLED)

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

// Process video frames in this queue
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;

// Blur
@property (nonatomic, strong) CALayer *blurLayer;
@property (nonatomic, strong) UIImage *blurImage;

#endif


@property (nonatomic, getter = isCameraRunning) BOOL cameraRunning;
@property (nonatomic, getter = isCapturingStillImage) BOOL capturingStillImage;

// Utilities
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;

// Camera
@property (nonatomic, strong) GPCameraView *cameraView;
@property (nonatomic, strong) CALayer *cameraOverlay;

@property (nonatomic, strong) UIView *flashView;

@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) UIImageView *capturedImageView;

// Toolbars
@property (nonatomic, strong) GPCameraViewTopToolbar *topToolbar;
@property (nonatomic, strong) GPCameraViewBottomToolbar *bottomToolbar;


// Designated initializer
- (instancetype)init;

@end
