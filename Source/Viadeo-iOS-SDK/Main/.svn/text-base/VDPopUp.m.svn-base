//
//  VDPopUp.m
//  MySuperApplication
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import "VDPopUp.h"
#import "VDConstants.h"

@implementation VDPopUp

#pragma mark -
#pragma mark Utils Method
BOOL is_iPad()
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
    return NO;
}

#pragma mark -
#pragma mark Init
- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        //Self
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentMode = UIViewContentModeRedraw;
        
        //Keyboard Boolean
        keyboardIsShown = NO;
        
        //Device Orientation
        deviceOrientation = UIDeviceOrientationUnknown;
        
        //Background Header
        UIImage *_image = [UIImage imageNamed:@"VDPopUp.bundle/images/connect_header.png"];
        backgroundHeaderImageView = [[UIImageView alloc] initWithImage:_image];
        backgroundHeaderImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:backgroundHeaderImageView];
        
        //Title Label
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:(is_iPad() ? 18.0 : 14.0)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:titleLabel];
        
        //Close Button
        closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        UIImage* closeImage = [UIImage imageNamed:@"VDPopUp.bundle/images/connect_close_button.png"];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(selectCloseButton) forControlEvents:UIControlEventTouchUpInside];
        closeButton.showsTouchWhenHighlighted = YES;
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:closeButton];
        
        //Web View
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(VD_POPUP_PADDING, VD_POPUP_PADDING, 320, 480)];
        webView.delegate = self;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.scalesPageToFit = YES;
        [self addSubview:webView];
        
        //Spinner
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                    UIActivityIndicatorViewStyleGray];
        spinner.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:spinner];
    }
    return self;
}

#pragma mark -
#pragma mark Deallocation
- (void)dealloc
{
    [self finishDismissing];
    
    [webPageURL release];
    webPageURL = nil;
    
    [backgroundHeaderImageView release];
    backgroundHeaderImageView = nil;
    
    [titleLabel release];
    titleLabel = nil;
    
    [closeButton release];
    closeButton = nil;
    
    [webView stopLoading];
    [webView release];
    webView.delegate = nil;
    
    [spinner release];
    spinner = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Observers Methods
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification" object:nil];
}

#pragma mark -
#pragma mark Rect Methods
- (void)drawRoundedRect:(CGRect)_rect radius:(float)_radius context:(CGContextRef)_contextRef
{
    CGContextBeginPath(_contextRef);
    CGContextSaveGState(_contextRef);
    
    _rect = CGRectOffset(CGRectInset(_rect, 0.5, 0.5), 0.5, 0.5);
    CGContextTranslateCTM(_contextRef, CGRectGetMinX(_rect)-0.5, CGRectGetMinY(_rect)-0.5);
    CGContextScaleCTM(_contextRef, _radius, _radius);
    
    CGFloat _width = CGRectGetWidth(_rect) / _radius;
    CGFloat _height = CGRectGetHeight(_rect) / _radius;
    
    CGContextMoveToPoint(_contextRef, _width, _height/2);
    
    CGContextAddArcToPoint(_contextRef, _width, _height, _width/2, _height, 1);
    CGContextAddArcToPoint(_contextRef, 0, _height, 0, _height/2, 1);
    CGContextAddArcToPoint(_contextRef, 0, 0, _width/2, 0, 1);
    CGContextAddArcToPoint(_contextRef, _width, 0, _width, _height/2, 1);
    
    CGContextClosePath(_contextRef);
    CGContextRestoreGState(_contextRef);
}

- (void)drawRect:(CGRect)_rect
{
    CGContextRef _contextRef = UIGraphicsGetCurrentContext();
    CGColorSpaceRef _spaceRef = CGColorSpaceCreateDeviceRGB();
    CGRect _borderRect = CGRectOffset(_rect, -0.5, -0.5);
    CGFloat _grayColor[4] = {0.25, 0.25, 0.25, 0.55};
    
    CGContextSaveGState(_contextRef);
    CGContextSetFillColor(_contextRef, _grayColor);
    [self drawRoundedRect:_borderRect radius:7.0 context:_contextRef];
    CGContextFillPath(_contextRef);
    CGContextRestoreGState(_contextRef);
    CGColorSpaceRelease(_spaceRef);
}

#pragma mark -
#pragma mark Device Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIDeviceOrientation)orientation
{
    if (orientation == deviceOrientation) {
        return NO;
    } else {
        return orientation == UIDeviceOrientationLandscapeLeft
        || orientation == UIDeviceOrientationLandscapeRight
        || orientation == UIDeviceOrientationPortrait
        || orientation == UIDeviceOrientationPortraitUpsideDown;
    }
}

- (CGAffineTransform)transformFromOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (void)updateViewOrientation:(BOOL)transform
{
    if (transform) { self.transform = CGAffineTransformIdentity; }
    
    CGRect _applicationFrame = [UIScreen mainScreen].applicationFrame;
    
    CGPoint center = CGPointMake(_applicationFrame.origin.x + (int)(_applicationFrame.size.width/2),_applicationFrame.origin.y + (int)(_applicationFrame.size.height/2));
    
    // Resize the popup on iPad
    CGFloat _scale = 1.0f;
    if (is_iPad()) { _scale = 0.75f; }
    
    CGFloat _width = (int)(_scale * _applicationFrame.size.width) - VD_POPUP_PADDING * 2;
    CGFloat _height = (int)(_scale * _applicationFrame.size.height) - VD_POPUP_PADDING * 2;
    
    deviceOrientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        self.frame = CGRectMake(VD_POPUP_PADDING, VD_POPUP_PADDING, _width, _height);
        backgroundHeaderImageView.frame = CGRectMake(backgroundHeaderImageView.frame.origin.x, backgroundHeaderImageView.frame.origin.y, _width - VD_POPUP_BORDER_WIDTH*2, titleLabel.frame.size.height);
    } else {
        self.frame = CGRectMake(VD_POPUP_PADDING, VD_POPUP_PADDING, _height, _width);
        backgroundHeaderImageView.frame = CGRectMake(backgroundHeaderImageView.frame.origin.x, backgroundHeaderImageView.frame.origin.y, _height - VD_POPUP_BORDER_WIDTH*2, titleLabel.frame.size.height);
    }
    
    self.center = center;
    
    if (transform) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        self.transform = [self transformFromOrientation:orientation];
    }
}

- (void)updateWebViewOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [webView stringByEvaluatingJavaScriptFromString:
         @"document.body.setAttribute('orientation', 90);"];
    } else {
        [webView stringByEvaluatingJavaScriptFromString:
         @"document.body.removeAttribute('orientation');"];
    }
}

#pragma mark -
#pragma mark Device Orientation Notification
- (void)deviceOrientationDidChange:(NSNotification *)_notification
{
    UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    if (!keyboardIsShown && [self shouldAutorotateToInterfaceOrientation:orientation]) {
        [self updateWebViewOrientation];
        
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [self updateViewOrientation:YES];
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark Keyboard Notifications
- (void)keyboardWillShow:(NSNotification*)notification
{
    keyboardIsShown = YES;
    
    // No need to resize the popup on iPad
    if (is_iPad()) { return; }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        webView.frame = CGRectInset(webView.frame, -(VD_POPUP_PADDING + VD_POPUP_BORDER_WIDTH),
                                    -(VD_POPUP_PADDING + VD_POPUP_BORDER_WIDTH) - titleLabel.frame.size.height);
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    keyboardIsShown = NO;
    
    // No need to resize the popup on iPad
    if (is_iPad()) { return; }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        webView.frame = CGRectInset(webView.frame, VD_POPUP_PADDING + VD_POPUP_BORDER_WIDTH,
                                    VD_POPUP_PADDING + VD_POPUP_BORDER_WIDTH + titleLabel.frame.size.height);
    }
}

#pragma mark -
#pragma mark Show Methods
- (void)updateSubviewsFrame
{
    CGFloat insideWidth = self.frame.size.width - VD_POPUP_BORDER_WIDTH*2;
    
    //Title Label
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(VD_POPUP_BORDER_WIDTH + VD_POPUP_TITLE_MARGIN_X*2, VD_POPUP_BORDER_HEIGHT, insideWidth - (titleLabel.frame.size.height + VD_POPUP_TITLE_MARGIN_X*2), titleLabel.frame.size.height + VD_POPUP_TITLE_MARGIN_Y*2);
    
    //Close Button
    [closeButton sizeToFit];
    closeButton.frame = CGRectMake(self.frame.size.width - (titleLabel.frame.size.height + VD_POPUP_BORDER_WIDTH), VD_POPUP_BORDER_WIDTH, titleLabel.frame.size.height, titleLabel.frame.size.height);
    
    // Background Header Image View
    backgroundHeaderImageView.frame = CGRectMake(VD_POPUP_BORDER_WIDTH, VD_POPUP_BORDER_HEIGHT, self.frame.size.width - VD_POPUP_BORDER_WIDTH*2, titleLabel.frame.size.height);
    
    //Web View
    webView.frame = CGRectMake(VD_POPUP_BORDER_WIDTH, VD_POPUP_BORDER_WIDTH + titleLabel.frame.size.height, insideWidth, self.frame.size.height - (titleLabel.frame.size.height + VD_POPUP_BORDER_WIDTH*2));
    
    //Spinner
    [spinner sizeToFit];
    [spinner startAnimating];
    spinner.center = webView.center;
}

- (void)show
{
    //Load Web View
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webPageURL]];
    [webView loadRequest:request];
    
    [self updateViewOrientation:NO];
    
    [self updateSubviewsFrame];
    
    //Add to Window
    UIWindow *_window = [[UIApplication sharedApplication] keyWindow];
    if (!_window) _window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [_window addSubview:self];
    
    //Update Self Transform to a little size
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.transform = CGAffineTransformScale([self transformFromOrientation:orientation], 0.01, 0.01);
    
    //Start Opening Animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:VD_POPUP_SHOW_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startBouncingAnimation)];
    self.transform = CGAffineTransformScale([self transformFromOrientation:orientation], 1.1, 1.1);
    [UIView commitAnimations];
    
    //Add Observers
    [self addObservers];
}

- (void)startBouncingAnimation
{
    [UIView beginAnimations:@"startBouncingAnimation" context:nil];
    [UIView setAnimationDuration:VD_POPUP_BOUNCING_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(stopBouncingAnimation)];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.transform = CGAffineTransformScale([self transformFromOrientation:orientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)stopBouncingAnimation
{
    [UIView beginAnimations:@"stopBouncingAnimation" context:nil];
    [UIView setAnimationDuration:VD_POPUP_BOUNCING_DURATION];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.transform = [self transformFromOrientation:orientation];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Dismiss Methods
- (void)finishDismissing
{
    [self removeObservers];
    [self removeFromSuperview];
}

- (void)dismiss:(BOOL)animated
{
    [webPageURL release];
    webPageURL = nil;
    
    if (animated) {
        [UIView beginAnimations:@"dismissingViadeoPopUp" context:nil];
        [UIView setAnimationDuration:VD_POPUP_DISMISSING_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(finishDismissing)];
        self.alpha = 0.0;
        [UIView commitAnimations];
    } else {
        [self finishDismissing];
    }
}

#pragma mark -
#pragma mark Close Button Method
- (void)selectCloseButton
{
    [self dismiss:YES];
}

@end
