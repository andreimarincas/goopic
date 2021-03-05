//
//  GPCameraViewController.m
//  Goopic
//
//  Created by andrei.marincas on 29/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCameraViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Constants

static const CGFloat kTopToolbarSize = 41.33f;
static const CGFloat kBottomToolbarSize = 100.0f;

static const CGFloat kGaussianBlur = 25.0f;
static const CGFloat kSmoothFactor = 0.6f;
static const CGFloat kBlurScale = 1.5f;

// Contexts

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;


#pragma mark - 
#pragma mark = Camera View

@implementation GPCameraView

+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self.videoLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    }
    
    return self;
}

- (AVCaptureVideoPreviewLayer *)videoLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.videoLayer.session = session;
}

- (AVCaptureSession *)session
{
    return self.videoLayer.session;
}

@end


#pragma mark - 
#pragma mark - Camera View Controller

@implementation GPCameraViewController

#pragma mark - Utils

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

// WARNING: This litle monster returns 'nan' values from time to time...
// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    GPLogIN();
    
    GPLog(@"gravity: %@", gravity);
    GPLog(@"frame size: %@", NSStringFromCGSize(frameSize));
    GPLog(@"aperture size: %@", NSStringFromCGSize(apertureSize));
    
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill])
    {
        if (viewRatio > apertureRatio)
        {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
        else
        {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    }
    else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect])
    {
        if (viewRatio > apertureRatio)
        {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
        else
        {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    }
    else if ([gravity isEqualToString:AVLayerVideoGravityResize])
    {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
    
	if (size.width < frameSize.width)
    {
		videoBox.origin.x = (frameSize.width - size.width) / 2;
    }
	else
    {
		videoBox.origin.x = (size.width - frameSize.width) / 2;
    }
	
	if (size.height < frameSize.height)
    {
		videoBox.origin.y = (frameSize.height - size.height) / 2;
    }
	else
    {
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    }
    
    GPLog(@"video box: %@", NSStringFromCGRect(videoBox));
    
    GPLogOUT();
	return videoBox;
}

// utility routing used during image capture to set up capture orientation
+ (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    
	if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
		result = AVCaptureVideoOrientationLandscapeRight;
    }
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
		result = AVCaptureVideoOrientationLandscapeLeft;
    }
    
	return result;
}

//+ (UIImage *)fixOrientation:(UIImage *)image
//{
//    const CGFloat degrees = 90;
//    return [image imageRotatedByDegrees:degrees];
//}

+ (CGImageRef)blurredImage:(CGImageRef)image
{
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image];
    
    // Apply Gausian filter to blur the image
    CIFilter *gaussianFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianFilter setValue:ciImage forKey:kCIInputImageKey];
    [gaussianFilter setValue:@( kGaussianBlur ) forKey:kCIInputRadiusKey];
    ciImage = [gaussianFilter valueForKey:kCIOutputImageKey];
    
    // Apply Bloom that makes soft edges and adds glow to image
    CIFilter *bloomFilter = [CIFilter filterWithName:@"CIBloom"];
    [bloomFilter setValue:ciImage forKey:kCIInputImageKey];
    [bloomFilter setValue:[NSNumber numberWithDouble: kSmoothFactor] forKey:@"inputRadius"];
    ciImage = [bloomFilter valueForKey:kCIOutputImageKey];
    
    static CIContext *context;
    
    if (!context)
    {
        context = [CIContext contextWithOptions:nil];
    }
    
    CGImageRef blurredImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
    return blurredImage;
}

#pragma mark - Init/Dealloc

- (instancetype)init
{
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        _deviceOrientation = [UIDevice currentDevice].orientation;
    }
    
    GPLogOUT();
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    self.stillImageOutput = nil;
    self.cameraDeviceInput = nil;
    self.sessionQueue = nil;
    self.session = nil;
    
//    self.videoDeviceInput = nil;
    self.videoDataOutput = nil;
    self.videoDataOutputQueue = nil;
//    self.videoSessionQueue = nil;
//    self.videoSession = nil;
    
    GPLogOUT();
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    GPLogIN();
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = GPCOLOR_DARK_BLACK;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Toolbars
    GPCameraViewTopToolbar *topToolbar = [[GPCameraViewTopToolbar alloc] init];
    topToolbar.delegate = self;
    [self.view addSubview:topToolbar];
    self.topToolbar = topToolbar;
    
    GPCameraViewBottomToolbar *bottomToolbar = [[GPCameraViewBottomToolbar alloc] init];
    bottomToolbar.delegate = self;
    [self.view addSubview:bottomToolbar];
    self.bottomToolbar = bottomToolbar;
    
    [self rotateControlsToOrientation:_deviceOrientation animated:NO];
    
    // Flash
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *flashValue = [userDefaults stringForKey:kCameraFlashKey];
    [topToolbar selectFlashButtonForValue:flashValue];
    
	[self setupCamera];
//    [self setupVideoCapture];
    
    CALayer *blurLayer = [CALayer layer];
    blurLayer.masksToBounds = YES;
    blurLayer.backgroundColor = [[UIColor blackColor] CGColor];
    blurLayer.opacity = 0;
    [self.view.layer addSublayer:blurLayer];
    self.blurLayer = blurLayer;
    
    GPLogOUT();
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    [super viewWillAppear:animated];
    
    [self showActivity:GPActivityStartingCamera animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                            selector: @selector(deviceOrientationChanged:)
                                                name: UIDeviceOrientationDidChangeNotification
                                              object: nil];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(captureSessionDidStartRunning:)
                                                 name: AVCaptureSessionDidStartRunningNotification
                                               object: nil];
    
    // Start the camera session
    dispatch_async(self.sessionQueue, ^{
        
		[self addObserver: self
               forKeyPath: @"sessionRunningAndDeviceAuthorized"
                  options: (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context: SessionRunningAndDeviceAuthorizedContext];
        
		[self addObserver: self
               forKeyPath: @"stillImageOutput.capturingStillImage"
                  options: (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                  context: CapturingStillImageContext];
        
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(subjectAreaDidChange:)
                                                     name: AVCaptureDeviceSubjectAreaDidChangeNotification
                                                   object: [self.cameraDeviceInput device]];
		
		__weak GPCameraViewController *weakSelf = self;
        
		self.runtimeErrorHandlingObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName: AVCaptureSessionRuntimeErrorNotification
                                                          object: self.session
                                                           queue: nil
                                                      usingBlock: ^(NSNotification *note) {
                                                          
                                                          GPCameraViewController *strongSelf = weakSelf;
                                                          
                                                          // Manually restarting the session since it must have been stopped due to an error.
                                                          [strongSelf.session startRunning];
                                                      }];
        [self.session startRunning];
	});
    
    // Start the video session
//    dispatch_async(self.videoSessionQueue, ^{
//        
//        __weak GPCameraViewController *weakSelf = self;
//        
//		self.videoRuntimeErrorHandlingObserver =
//        [[NSNotificationCenter defaultCenter] addObserverForName: AVCaptureSessionRuntimeErrorNotification
//                                                          object: self.videoSession
//                                                           queue: nil
//                                                      usingBlock: ^(NSNotification *note) {
//                                                          
//                                                          GPCameraViewController *strongSelf = weakSelf;
//                                                          
//                                                          // Manually restarting the session since it must have been stopped due to an error.
//                                                          [strongSelf.videoSession startRunning];
//                                                      }];
//        [self.videoSession startRunning];
//    });
    
    if (![[UIApplication sharedApplication] isStatusBarHidden])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    GPLogOUT();
}

- (void)viewDidDisappear:(BOOL)animated
{
    GPLogIN();
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: AVCaptureSessionDidStartRunningNotification
                                                  object: nil];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIDeviceOrientationDidChangeNotification
                                                  object: nil];
    
    // Stop the camera session
	dispatch_async(self.sessionQueue, ^{
        
        [self.session stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: AVCaptureDeviceSubjectAreaDidChangeNotification
                                                      object: [self.cameraDeviceInput device]];
        
		[[NSNotificationCenter defaultCenter] removeObserver:self.runtimeErrorHandlingObserver];
		
		[self removeObserver: self
                  forKeyPath: @"sessionRunningAndDeviceAuthorized"
                     context: SessionRunningAndDeviceAuthorizedContext];
        
		[self removeObserver: self
                  forKeyPath: @"stillImageOutput.capturingStillImage"
                     context: CapturingStillImageContext];
        

	});
// Video data output cleanup
//        AVCaptureConnection *videoOutputConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
//        [videoOutputConnection setEnabled:NO];
//
//        [self.session removeOutput:self.videoDataOutput];
//
//        [self.videoDataOutput setSampleBufferDelegate:nil queue:NULL];
    
    // Stop the video session
//    dispatch_async(self.videoSessionQueue, ^{
//        
//        [self.videoSession stopRunning];
//        
//		[[NSNotificationCenter defaultCenter] removeObserver:self.videoRuntimeErrorHandlingObserver];
//	});
    
    GPLogOUT();
}

#pragma mark - Camera Setup

- (void)setupCamera
{
    GPLogIN();
    
    // Create the capture session
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset640x480;
	self.session = session;
    
    // Setup the camera view
    GPCameraView *cameraView = [[GPCameraView alloc] init];
    [cameraView setSession:session];
    [self.view addSubview:cameraView];
    self.cameraView = cameraView;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExposeTap:)];
    [cameraView addGestureRecognizer:tapGr];
    
    // Dispatch session setup to the sessionQueue so that the main queue isn't blocked
    dispatch_queue_t sessionQueue = dispatch_queue_create("CameraSessionQueue", DISPATCH_QUEUE_SERIAL);
	self.sessionQueue = sessionQueue;
    
    // Check for device authorization
	[self checkDeviceAuthorizationStatus];
    
    dispatch_async(self.sessionQueue, ^{
        
        // Get the video device (back camera)
		AVCaptureDevice *videoDevice = [GPCameraViewController deviceWithMediaType:AVMediaTypeVideo
                                                                preferringPosition:AVCaptureDevicePositionBack];
        
        // TODO: Adjust activeVideoMinFrameDuration and activeVideoMaxFrameDuration on AVCaptureDevice
        
        // Set the video input
        NSError *error = nil;
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
		{
			GPLogErr(@"%@ %@", error, [error userInfo]);
            self.session = nil;
            
            GPLogOUT();
            return;
		}
        
        if ([self.session canAddInput:videoDeviceInput])
		{
			[self.session addInput:videoDeviceInput];
			self.cameraDeviceInput = videoDeviceInput;
            
			dispatch_async(dispatch_get_main_queue(), ^{
                
                // The backing layer for camera view and the view can only be manipulated on main thread.
                [[self.cameraView.videoLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
			});
		}
        
        // Set the image output
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [stillImageOutput setOutputSettings:@{ AVVideoCodecKey : AVVideoCodecJPEG }];
        
		if ([self.session canAddOutput:stillImageOutput])
		{
			[self.session addOutput:stillImageOutput];
			self.stillImageOutput = stillImageOutput;
		}
        
        // Set the video data output
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        id rgbOutputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA) };
        
        [videoDataOutput setVideoSettings:rgbOutputSettings];
        [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
        
        // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
        self.videoDataOutputQueue = videoDataOutputQueue;
        
        if ([self.session canAddOutput:videoDataOutput])
        {
            [self.session addOutput:videoDataOutput];
            self.videoDataOutput = videoDataOutput;
        }
        
        AVCaptureConnection *videoOutputConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        [videoOutputConnection setEnabled:YES];
    });
    
    GPLogOUT();
}

//- (void)setupVideoCapture
//{
//    // Create the video session
//	AVCaptureSession *videoSession = [[AVCaptureSession alloc] init];
//    videoSession.sessionPreset = AVCaptureSessionPreset640x480;
//	self.videoSession = videoSession;
//    
//    // Dispatch session setup to the sessionQueue so that the main queue isn't blocked
//    dispatch_queue_t videoSessionQueue = dispatch_queue_create("VideoSessionQueue", DISPATCH_QUEUE_SERIAL);
//	self.videoSessionQueue = videoSessionQueue;
//    
//    dispatch_async(self.videoSessionQueue, ^{
//        
//        // Get the video device (back camera)
//		AVCaptureDevice *videoDevice = [GPCameraViewController deviceWithMediaType:AVMediaTypeVideo
//                                                                preferringPosition:AVCaptureDevicePositionBack];
//        
//        // TODO: Adjust activeVideoMinFrameDuration and activeVideoMaxFrameDuration on AVCaptureDevice
//        
//        // Set the video input
//        NSError *error = nil;
//		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
//        
//        if (error)
//		{
//			GPLogErr(@"%@ %@", error, [error userInfo]);
//            self.videoSessionQueue = nil;
//            
//            GPLogOUT();
//            return;
//		}
//        
//        if ([self.videoSession canAddInput:videoDeviceInput])
//		{
//			[self.videoSession addInput:videoDeviceInput];
//			self.videoDeviceInput = videoDeviceInput;
//		}
//        
//        // Set the video data output
//        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
//        
//        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
//        id rgbOutputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA) };
//        
//        [videoDataOutput setVideoSettings:rgbOutputSettings];
//        [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
//        
//        // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
//        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
//        // see the header doc for setSampleBufferDelegate:queue: for more information
//        dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
//        [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
//        self.videoDataOutputQueue = videoDataOutputQueue;
//        
//        if ([self.videoSession canAddOutput:videoDataOutput])
//        {
//            [self.videoSession addOutput:videoDataOutput];
//            self.videoDataOutput = videoDataOutput;
//        }
//        
//        AVCaptureConnection *videoOutputConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
//        [videoOutputConnection setEnabled:YES];
//    });
//}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - Update UI

- (void)updateUI
{
    GPLogIN();
    [super updateUI];
    
    self.cameraView.frame = CGRectMake(0, kTopToolbarSize,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - kTopToolbarSize - kBottomToolbarSize);
    [self.cameraView setNeedsDisplay];
    
    GPLog(@"camera view :%@", self.cameraView);
    
    self.topToolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kTopToolbarSize);
    [self.topToolbar updateUI];
    [self.view bringSubviewToFront:self.topToolbar];
    
    GPLog(@"top toolbar: %@", self.topToolbar);
    
    self.bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height - kBottomToolbarSize,
                                          self.view.bounds.size.width, kBottomToolbarSize);
    [self.bottomToolbar updateUI];
    [self.view bringSubviewToFront:self.bottomToolbar];
    
    GPLog(@"bottom toolbar: %@", self.bottomToolbar);
    
    [CALayer performWithoutAnimation:^{
        
//        CATransform3D t = self.blurLayer.transform;
//        self.blurLayer.transform = CATransform3DIdentity;
        
//        self.blurLayer.bounds = self.cameraView.bounds;
//        self.blurLayer.position = self.cameraView.center;
        
//        self.blurLayer.transform = t;
        
        self.blurLayer.bounds = CGRectMake(0, 0, self.cameraView.bounds.size.height, self.cameraView.bounds.size.width);
        self.blurLayer.position = self.cameraView.center;
        
        CATransform3D t = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
        t = CATransform3DScale(t, kBlurScale, kBlurScale, 0);
        self.blurLayer.transform = t;
        
        GPLog(@"camera view frame: %@", NSStringFromCGRect(self.cameraView.frame));
        GPLog(@"blur layer: %@", NSStringFromCGRect(self.blurLayer.frame));
        
        [self.blurLayer removeFromSuperlayer];
        [self.view.layer insertSublayer:self.blurLayer above:self.cameraView.layer];
    }];
    
    [self.view.layer bringSublayerToFront:self.topToolbar.layer];
    [self.view.layer bringSublayerToFront:self.bottomToolbar.layer];
    [self.view bringSubviewToFront:self.topToolbar];
    [self.view bringSubviewToFront:self.bottomToolbar];
    
    GPLogOUT();
}

#pragma mark - Key-Value Observer

// perform a flash bulb animation using KVO to monitor the value of the capturingStillImage property of the AVCaptureStillImageOutput class
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
    {
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
        {
            GPLog(@"is capturing still image...");
            
//            [self runStillImageCaptureAnimation];
            
//			// do flash bulb like animation
//			flashView = [[UIView alloc] initWithFrame:[self.cameraView frame]];
//			[flashView setBackgroundColor:[UIColor whiteColor]];
//			[flashView setAlpha:0.f];
//			[[[self view] window] addSubview:flashView];
//			
//			[UIView animateWithDuration:.4f
//							 animations:^{
//								 [flashView setAlpha:1.f];
//							 }
//			 ];
		}
		else
        {
//			[UIView animateWithDuration:.4f
//							 animations:^{
//								 [flashView setAlpha:0.f];
//							 }
//							 completion:^(BOOL finished){
//								 [flashView removeFromSuperview];
//								 flashView = nil;
//							 }
//			 ];
		}
	}
    else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
//        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            if (isRunning)
//            {
//                [[self cameraButton] setEnabled:YES];
//                [[self recordButton] setEnabled:YES];
//                [[self stillButton] setEnabled:YES];
//            }
//            else
//            {
//                [[self cameraButton] setEnabled:NO];
//                [[self recordButton] setEnabled:NO];
//                [[self stillButton] setEnabled:NO];
//            }
//        });
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - Image Processing

// utility routine used after taking a still image to write the resulting image to the camera roll
//- (BOOL)writeCGImageToCameraRoll:(CGImageRef)cgImage withMetadata:(NSDictionary *)metadata
//{
//	CFMutableDataRef destinationData = CFDataCreateMutable(kCFAllocatorDefault, 0);
//	CGImageDestinationRef destination = CGImageDestinationCreateWithData(destinationData, 
//																		 CFSTR("public.jpeg"), 
//																		 1, 
//																		 NULL);
//	BOOL success = (destination != NULL);
//	require(success, bail);
//    {
//	const float JPEGCompQuality = 0.85f; // JPEGHigherQuality
//	CFMutableDictionaryRef optionsDict = NULL;
//	CFNumberRef qualityNum = NULL;
//	
//	qualityNum = CFNumberCreate(0, kCFNumberFloatType, &JPEGCompQuality);    
//	if ( qualityNum ) {
//		optionsDict = CFDictionaryCreateMutable(0, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
//		if ( optionsDict )
//			CFDictionarySetValue(optionsDict, kCGImageDestinationLossyCompressionQuality, qualityNum);
//		CFRelease( qualityNum );
//	}
//	
//	CGImageDestinationAddImage( destination, cgImage, optionsDict );
//	success = CGImageDestinationFinalize( destination );
//
//	if ( optionsDict )
//		CFRelease(optionsDict);
//	
//	require(success, bail);
//	
//	CFRetain(destinationData);
//	ALAssetsLibrary *library = [ALAssetsLibrary new];
//	[library writeImageDataToSavedPhotosAlbum:(__bridge id)destinationData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
//		if (destinationData)
//			CFRelease(destinationData);
//	}];
//    }
//
//bail:
//    {
//	if (destinationData)
//		CFRelease(destinationData);
//	if (destination)
//		CFRelease(destination);
//	return success;
//    }
//}

// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll
//- (void)takePicture
//{
//	// Find out the current orientation and tell the still image output.
//	AVCaptureConnection *stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
//	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
//	[stillImageConnection setVideoOrientation:avcaptureOrientation];
//	[stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
//	
//    // set the appropriate pixel format / image type output setting
//    [_stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey]];
//	
//	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
//		completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//            
//            if (!error)
//            {
//                NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
//                                                                            imageDataSampleBuffer,
//                                                                            kCMAttachmentMode_ShouldPropagate);
//                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//                [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments
//                                          completionBlock:^(NSURL *assetURL, NSError *error) {
//                    if (!error) {
//                        GPLog(@"Image saved to camera roll.");
//                    } else
//                    {
//                        GPLogErr(@"%@ %@", error, [error userInfo]);
//                    }
//                }];
//            }
//            else
//            {
//                GPLogErr(@"%@ %@", error, [error userInfo]);
//            }
//		}
//	 ];
//}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    GPLogIN();
    
        __weak typeof(self) weakSelf = self;
    
        @autoreleasepool {
            
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            
            /* Lock the image buffer */
            CVPixelBufferLockBaseAddress(imageBuffer, 0);
            
            /* Get information about the image */
            uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
            size_t bytesPerRow   = CVPixelBufferGetBytesPerRow(imageBuffer);
            size_t width         = CVPixelBufferGetWidth(imageBuffer);
            size_t height        = CVPixelBufferGetHeight(imageBuffer);
            
            /* Create a CGImageRef from the CVImageBufferRef */
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                            width,
                                                            height,
                                                            8,
                                                            bytesPerRow,
                                                            colorSpace,
                                                            kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
            CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
            
//            GPLog(@"image size: h %zu, w %zu", height, width);
            
            // unlock the  image buffer
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            
            // release some components
            CGContextRelease(newContext);
            CGColorSpaceRelease(colorSpace);
            
            CGImageRef cgBlurredImage = [GPCameraViewController blurredImage:cgImage];
            CGImageRelease(cgImage);
            
            CGImageRelease(_cgImage);
            _cgImage = cgBlurredImage;
            
//            [weakSelf.blurLayer setContents:(__bridge id)cgBlurredImage];
            
//            UIImage *blurredImage = [[UIImage alloc] initWithCGImage:cgBlurredImage];
//            CGImageRelease(cgBlurredImage);
            
//            blurredImage = [GPCameraViewController fixOrientation:blurredImage];
            
//             blurImage = blurredImage;
//            _blurImageOrientation = [[UIDevice currentDevice] orientation];
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf setCameraBlurImage:blurredImage animated:NO];
//                self.blurLayer.opacity = 0.35;
//            });
            
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                
//                CGImageRef cgBlurredImage = [GPCameraViewController blurredImage:cgImage];
//                CGImageRelease(cgImage);
//                
//                
////
//                UIImage *blurredImage = [[UIImage alloc] initWithCGImage:cgBlurredImage];
//                CGImageRelease(cgBlurredImage);
////
//                blurredImage = [GPCameraViewController fixOrientation:blurredImage];
////
//                dispatch_async(dispatch_get_main_queue(), ^{
////
//                    _blurImage = blurredImage;
//                    _blurImageOrientation = [[UIDevice currentDevice] orientation];
////
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                static UIApplicationState lastAppState = UIApplicationStateActive;
                static NSDate *lastAppStateChangeTime = nil;
                
                NSDate *now = [NSDate now];
                
                if (!lastAppStateChangeTime) {
                    lastAppStateChangeTime = now;
                }
                
                UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
                
                if (appState != lastAppState)
                {
                    lastAppState = appState;
                    lastAppStateChangeTime = now;
                }
                
                if ([now timeIntervalSinceDate:lastAppStateChangeTime] >= 0.3)
                {
                
                
                    if (appState == UIApplicationStateInactive)
                    {
                        GPLog(@"Application inactive, setting the blur image.");
                        
                        
//                            [weakSelf setCameraBlur:YES animated:NO];
                        
//                        if ([weakSelf.blurLayer contents] == nil)
                        {
                            [weakSelf.blurLayer setContents:(__bridge id)(_cgImage)];
                            [weakSelf.blurLayer setOpacity:1.0f];
                            [self updateUI];
                        }
                        
                        ////    dispatch_async(dispatch_get_main_queue(), ^{
                        //
                        //        [CALayer performWithoutAnimation:^{
                        //
                        //            if (blur)
                        //            {
                        //                self.blurLayer.contents = (__bridge id)(_cgImage);
                        //                //            const CGFloat scale = 1.5;
                        //                //            self.blurLayer.transform = CATransform3DMakeScale(scale, scale, 0);
                        //                self.blurLayer.opacity = 1; // TODO: if animated
                        //            }
                        //            else
                        //            {
                        //                self.blurLayer.opacity = 0; // TODO: if animated
                        //                self.blurLayer.contents = nil;
                        //                self.blurLayer.transform = CATransform3DIdentity;
                        //            }
                        //            
                        //            [self updateUI];
                        //        }];
                        ////    });
                        
//                        weakSelf.blurLayer.contents = (__bridge id)(_cgImage);
//                        [self updateUI];
                        
                    }
                else if (appState == UIApplicationStateActive)
                {
                    if ([weakSelf.blurLayer contents] != nil)
                    {
                    [weakSelf.blurLayer setContents:nil];
                    [weakSelf.blurLayer setOpacity:0.0f];
                    [self updateUI];
                    }
                }
                }
                });
//
//                    
////                    [weakSelf.blurLayer setContents:(__bridge id)cgImage];
////                    weakSelf.blurLayer.opacity = 1;
////                    CGImageRelease(_cgImage);
////                    _cgImage = cgImage;
////                    [self updateUI];
//                });
//                
//                
//            });
        }
        
//        [NSThread sleepForTimeInterval:0.05];
    
    GPLogOUT();
}

#pragma mark - Camera Blur

//// image: pass nil to remove the camera blur
//- (void)setCameraBlur:(BOOL)blur animated:(BOOL)animated
////- (void)setBlur:(BOOL)blur animated:(BOOL)animated inTr
//{
//    GPLogIN();
//    
////    dispatch_async(dispatch_get_main_queue(), ^{
//    
//        [CALayer performWithoutAnimation:^{
//    
//            if (blur)
//            {
//                self.blurLayer.contents = (__bridge id)(_cgImage);
//                //            const CGFloat scale = 1.5;
//                //            self.blurLayer.transform = CATransform3DMakeScale(scale, scale, 0);
//                self.blurLayer.opacity = 1; // TODO: if animated
//            }
//            else
//            {
//                self.blurLayer.opacity = 0; // TODO: if animated
//                self.blurLayer.contents = nil;
//                self.blurLayer.transform = CATransform3DIdentity;
//            }
//            
//            [self updateUI];
//        }];
////    });
//    
//    GPLogOUT();
//}

//- (BOOL)hasCameraBlur
//{
//    return ([self.blurLayer contents] != nil);
//}

#pragma mark - Gesture Recognizers

- (void)handleTap:(UITapGestureRecognizer *)tapGr
{
    GPLogIN();
    
    //
//    if (![self hasCameraBlur]) {
//        [self setCameraBlurImage:_blurImage animated:NO];
//    }
//    else {
//        [self setCameraBlurImage:nil animated:NO];
//    }
    //
    
    GPLogOUT();
}

#pragma mark - App Notifications

- (void)appWillResignActive
{
    GPLogIN();
    [super appWillResignActive];
    
    [self.session removeOutput:self.videoDataOutput];
    
    [CALayer performWithoutAnimation:^{
        
        [self.blurLayer setContents:(__bridge id)(_cgImage)];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        anim.duration = 0.3;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = YES;
        anim.fromValue = @(0.0f);
        anim.toValue = @(1.0f);
        [self.blurLayer addAnimation:anim forKey:@"blur-anim-show"];
        [self.blurLayer setOpacity:1.0f];
        [self updateUI];
    }];
    
    [self.session addOutput:self.videoDataOutput];
    
    
////    if (![self hasCameraBlur])
//    {
////        [self setCameraBlur:YES animated:NO];
//        
//        
//        
////        self.blurLayer.contents = (__bridge id)(_cgImage);
////        self.blurLayer.opacity = 1;
////        [self updateUI];
//    }
    
//    if (!_blurTimer)
//    {
////        _blurTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
////                                                      target: self
////                                                    selector: @selector(updateBlur:)
////                                                    userInfo: nil
////                                                     repeats: YES];
//    }
    
    GPLogOUT();
}

- (void)appDidEnterBackground
{
    [super appDidEnterBackground];
    
    [self.blurLayer removeAllAnimations];
}

//- (void)updateBlur:(NSTimer *)timer
//{
////    __weak typeof(self) weakSelf = self;
////    
////    dispatch_async(self.sessionQueue, ^{
////        
////        UIImage *img = [[UIImage alloc] initWithCGImage:_cgImage];
////        
////        dispatch_async(dispatch_get_main_queue(), ^{
////            [weakSelf.blurLayer setContents:(__bridge id)([img CGImage])];
////        });
////    });
//    
//    __weak typeof(self) weakSelf = self;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf.blurLayer setContents:(__bridge id)(_cgImage)];
//    });
//}

- (void)appDidBecomeActive
{
    GPLogIN();
    [super appDidBecomeActive];
    
//    [_blurTimer invalidate];
//    _blurTimer = nil;
    
////    if ([self hasCameraBlur])
//    {
//        [self setCameraBlur:NO animated:YES];
//        
//        [self.session addOutput:self.videoDataOutput];
//    }
    
//    [self.session removeOutput:self.videoDataOutput];
    
    [CALayer performWithoutAnimation:^{
        
//        [self.blurLayer setContents:nil];
//        [self.blurLayer setOpacity:0.0f];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        anim.duration = 0.3;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = YES;
        anim.fromValue = @(1.0f);
        anim.toValue = @(0.0f);
        [self.blurLayer addAnimation:anim forKey:@"blur-anim-hide"];
        [self.blurLayer setOpacity:0.0f];
        
        [self updateUI];
    }];
    
//    [self.session addOutput:self.videoDataOutput];
    
    GPLogOUT();
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (deviceOrientation != _deviceOrientation)
    {
        [self rotateControlsToOrientation:deviceOrientation animated:YES];
        _deviceOrientation = deviceOrientation;
    }
}

- (void)rotateControlsToOrientation:(UIDeviceOrientation)toDeviceOrientation animated:(BOOL)animated
{
    GPLogIN();
    
    CGFloat angle = 0;
    
    if (toDeviceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        angle = M_PI_2;
    }
    else if (toDeviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        angle = -M_PI_2;
    }
    
    [self.topToolbar setButtonsRotation:angle animated:animated];
    [self.bottomToolbar setButtonsRotation:angle animated:animated];
    
    GPLogOUT();
}

#pragma mark - Activity View

- (CGRect)preferredActivityViewFrame
{
    return CGRectMake(0, kTopToolbarSize,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - kTopToolbarSize - kBottomToolbarSize);
}

- (UIColor *)preferredActivityViewBackgroundColor
{
    return GPCOLOR_DARK_BLACK;
}

- (void)captureSessionDidStartRunning:(NSNotification *)notification
{
    GPLogIN();
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf hideActivityAnimated:YES];
    });
    
//    dispatch_async(self.sessionQueue, ^{
//       
//        // Set the video data output
//        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
//        
//        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
//        id rgbOutputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA) };
//        
//        [videoDataOutput setVideoSettings:rgbOutputSettings];
//        [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
//        
//        // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
//        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
//        // see the header doc for setSampleBufferDelegate:queue: for more information
//        dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
//        [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
//        self.videoDataOutputQueue = videoDataOutputQueue;
//        
//        if ([self.session canAddOutput:videoDataOutput])
//        {
//            [self.session addOutput:videoDataOutput];
//            self.videoDataOutput = videoDataOutput;
//        }
//        
//        AVCaptureConnection *videoOutputConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
//        [videoOutputConnection setEnabled:YES];
//    });
    
    GPLogOUT();
}

#pragma mark - Focus and Exposure

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    GPLogIN();
    GPLog(@"point: %@", NSStringFromCGPoint(point));
    
	dispatch_async(self.sessionQueue, ^{
        
		AVCaptureDevice *device = [self.cameraDeviceInput device];
		NSError *error = nil;
        
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
            
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
            
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			GPLog(@"%@ %@", error, [error userInfo]);
		}
	});
    
    GPLogOUT();
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    GPLogIN();
    
	CGPoint devicePoint = CGPointMake(.5, .5);
    
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
    
    GPLogOUT();
}

- (void)focusAndExposeTap:(UITapGestureRecognizer *)tapGr
{
    GPLogIN();
    
	CGPoint devicePoint = [self.cameraView.videoLayer captureDevicePointOfInterestForPoint:[tapGr locationInView:tapGr.view]];
    
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    
//    ///
//    if (![self.cameraView hasCameraBlur])
//    {
//        [self captureSnapshotWithCompletion:^(UIImage *image) {
//            [self.cameraView addCameraBlurWithSnapshot:image];
//        }];
//    }
//    else
//    {
//        [self.cameraView removeCameraBlur];
//    }
//    ///
    
    GPLogOUT();
}

#pragma mark - Device Authorization

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [self.session isRunning] && [self isDeviceAuthorized];
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType
                             completionHandler:^(BOOL granted)
     {
         if (granted)
         {
             // Granted access to mediaType
             [self setDeviceAuthorized:YES];
         }
         else
         {
             // Not granted access to mediaType
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 GPLogErr(@"AVCam doesn't have permission to use Camera, please change privacy settings");
                 
                 //                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                 //                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                 //                                           delegate:self
                 //                                  cancelButtonTitle:@"OK"
                 //                                  otherButtonTitles:nil] show];
                 
                 // TODO: Show appropriate error message & dismiss controller
                 
                 [self setDeviceAuthorized:NO];
             });
         }
     }];
}

#pragma mark - Toolbar Delegate

- (void)toolbar:(id)toolbar didSelectButton:(UIButton *)button
{
    GPLogIN();
    GPLog(@"button: %@", button);
    
    if (toolbar == self.topToolbar)
    {
        GPLog(@"flash selection changed");
    }
    else // bottom toolbar
    {
        if (button == self.bottomToolbar.cancelButton)
        {
            button.enabled = NO;
            
            [self dismissViewControllerAnimated:YES completion:^{
                button.enabled = YES;
            }];
        }
        else if (button == self.bottomToolbar.takeButton)
        {
            button.enabled = NO;
        }
    }
    
    GPLogOUT();
}

@end
