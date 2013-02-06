//
//  VDLoginPopUp.h
//  MySuperApplication
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDPopUp.h"

@protocol VDLoginPopUpDelegate;

@interface VDLoginPopUp : VDPopUp {
    id<VDLoginPopUpDelegate> loginDelegate;
    NSString *clientID;
    NSString *clientSecret;
    NSURLConnection *urlConnection;
    NSMutableData *receivedData;
}

//Init
- (id)initWithURL:(NSString *)_webPageURL ClientID:(NSString *)_clientID ClientSecret:(NSString *)_clientSecret Delegate:(id)_delegate;

@end

@protocol VDLoginPopUpDelegate <NSObject>

@optional

- (void)viadeoPopUpDidLogin:(NSString *)_accessToken;
- (void)viadeoPopUpDidNotLogin:(BOOL)_canceled withError:(NSError *)_error;

@end
