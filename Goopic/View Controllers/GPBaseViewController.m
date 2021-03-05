//
//  GPBaseViewController.m
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPBaseViewController.h"
#import "GPBaseView+Private.h"

#pragma mark -
#pragma mark - Base Controller's View

@implementation GPBaseView

#pragma mark - Init / Dealloc

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    GPLogIN();
    
    // Custom initialization
    
    GPLogOUT();
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

#pragma mark - Geometry Updates

- (void)setBounds:(CGRect)bounds
{
    GPLogIN();
    [super setBounds:bounds];
    
    // Call updateUI if NOT rotating interface orientation, otherwise let the base view controller updateUI in the animation block
    if (!self.baseViewController.isRotatingInterfaceOrientation)
    {
        [self.baseViewController updateUI];
    }
    
    GPLogOUT();
}

- (void)setFrame:(CGRect)frame
{
    GPLogIN();
    [super setFrame:frame];
    
    // Call updateUI if NOT rotating interface orientation, otherwise let the base view controller updateUI in the animation block
    if (!self.baseViewController.isRotatingInterfaceOrientation)
    {
        [self.baseViewController updateUI];
    }
    
    GPLogOUT();
}

@end


#pragma mark -
#pragma mark - Base View Controller

@implementation GPBaseViewController

#pragma mark - Init / Dealloc

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

#pragma mark - View Lifecycle

- (void)loadView
{
    GPLogIN();
    [super loadView];
    
    GPBaseView *baseView = [[GPBaseView alloc] init];
    baseView.frame = [[UIScreen mainScreen] bounds];
    baseView.baseViewController = self;
    self.view = baseView;
    
    GPLogOUT();
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    GPLog(@"%@", [self description]);
    
    // Ensure the updateUI is called because view's bounds may never change
    [self updateUI];
    
    GPLogOUT();
}

#pragma mark - Interface Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _rotatingInterfaceOrientation = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateUI];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    _rotatingInterfaceOrientation = NO;
}

#pragma mark - Properties

- (GPBaseView *)baseView
{
    return (GPBaseView *)self.view;
}

#pragma mark - Interface Update

- (void)updateUI
{
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}

@end
