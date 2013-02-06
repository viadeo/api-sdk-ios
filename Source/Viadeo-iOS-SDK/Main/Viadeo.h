//
//  Viadeo.h
//  MySuperApplication
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ViadeoConnectDelegate;

@class VDLoginPopUp, VDRequest;

@interface Viadeo : NSObject {
    id<ViadeoConnectDelegate> delegate;
    NSString *clientSecret;
    VDLoginPopUp *loginPopUp;
    NSMutableArray *requestsArray;
}

@property (nonatomic, retain) NSString *clientID, *accessToken, *sessionID;

// Init Method
- (id)initWithClientID:(NSString *)_clientID ClientSecret:(NSString *)_clientSecret Delegate:(id)_delegate;

// Object Methods
+ (NSString *)readObjectForKey:(NSString *)_key;
+ (void)saveObject:(NSString *)_object forKey:(NSString *)_key;
+ (void)removeObjectForKey:(NSString *)_key;

// Token Method
- (void)saveAccessToken:(NSString *)_accessToken forCliendID:(NSString *)_clientID;

// Session ID Method
- (void)saveSessionID:(NSString *)_session forCliendID:(NSString *)_clientID;

// Authorize Method
- (void)authorize;

// Request Methods
- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andQuery:(NSDictionary *)_query andParams:(NSDictionary *)_params andUserInfo:(id)_userInfo andObject:(id)_object andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured;

- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured;

- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andQuery:(NSDictionary *)_query andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured;

- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andParams:(NSDictionary *)_params andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured;

- (NSArray *)requestsForObject:(id)_object;

// Cancel Methods
- (void)cancelAllRequests;
- (void)cancelRequestsForObject:(id)_object;
- (void)cancelRequestsForGraphPath:(NSString *)_graphPath;

// Log Methods
+ (BOOL)isLoggedIn;
- (void)logOut;

@end

@protocol ViadeoConnectDelegate <NSObject>

@optional

- (void)viadeoConnectDidLogin:(NSString *)_accessToken;
- (void)viadeoConnectDidNotLogin:(BOOL)_canceled withError:(NSError *)_error;

@end
