//
//  VDPopUp.h
//  MySuperApplication
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDPopUp : UIView <UIWebViewDelegate>
{
    //Header Background
    UIImageView *backgroundHeaderImageView;
    
    // Title Label
    UILabel *titleLabel;
    
    // Close Button
    UIButton *closeButton;
    
    // Web components
    UIWebView *webView;
    NSString *webPageURL;
    UIActivityIndicatorView *spinner;
    
    // Device Orientation
    UIDeviceOrientation deviceOrientation;
    
    // Keyboard Boolean
    BOOL keyboardIsShown;
}

// Methods
- (void)show;
- (void)dismiss:(BOOL)animated;

@end

@interface VDPopUp (Private)
- (void)finishDismissing;
- (void)updateWebViewOrientation;
@end
