//
//  VDRequest.h
//  MySuperApplication
//
//  Created by Viadeo on 31/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VD_REQUEST_CANCEL @"VD_REQUEST_CANCEL"
#define VD_REQUEST_WILL_FINISH_LOADING @"VD_REQUEST_WILL_FINISH_LOADING"
#define VD_REQUEST_DID_FINISH_LOADING @"VD_REQUEST_DID_FINISH_LOADING"
#define VD_REQUEST_DID_FAIL_WITH_ERROR @"VD_REQUEST_DID_FAIL_WITH_ERROR"

@protocol VDRequestDelegate;

@interface VDRequest : NSObject {
    BOOL enabledLogs, enabledErrorLogs;
    id <VDRequestDelegate> delegate;
    NSURLConnection *urlConnection;
    NSThread *readJsonFileThread;
}

@property (nonatomic) BOOL isWaitingForResponse, isDownloading, isCancelled;
@property (nonatomic, assign) id <VDRequestDelegate> delegate;
@property (nonatomic, assign) id object;
@property (nonatomic, retain) NSString *httpURL;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSString *graphPath;
@property (nonatomic, retain) NSDictionary *header;
@property (nonatomic, retain) NSDictionary *query;
@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLResponse *urlResponse;
@property (nonatomic) int retryCount;

// Utils Methods
- (BOOL)isEqualToRequest:(VDRequest *)_request;
+ (NSString *)getQuery:(NSDictionary *)_query;
+ (NSString *)getBody:(NSDictionary *)_params withAccessToken:(NSString *)_accessToken;
- (void)insertBody:(NSDictionary *)_params withAccessToken:(NSString *)_accessToken;

// Send Methods
- (void)send;
- (void)sendWithBody:(NSString *)_body isZipped:(BOOL)_isZipped;

// Cancel Method
- (void)cancel;

@end

@protocol VDRequestDelegate <NSObject>

@optional

- (void)viadeoRequest:(VDRequest *)_request didLoadDictionary:(NSDictionary *)_dictionary;
- (void)viadeoRequest:(VDRequest *)_request didLoadImagesDatasGroup:(NSArray *)imagesDatas isLarge:(BOOL)_isLarge fromCache:(BOOL)_fromCache;
- (void)viadeoRequest:(VDRequest *)_request didLoadImageData:(NSData *)_imageData fromCache:(BOOL)_fromCache;
- (void)viadeoRequest:(VDRequest *)_request didFailWithError:(NSError *)_error;

@end
