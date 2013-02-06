//
//  Viadeo.m
//  MySuperApplication
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import "Viadeo.h"
#import "VDLoginPopUp.h"
#import "VDConstants.h"
#import "VDRequest.h"

@interface Viadeo (Private)
+ (NSString *)readAccessTokenForCliendID:(NSString *)_cliendID;
+ (void)removeAccessTokenForClientID:(NSString *)_clientID;
- (void)cancelAllRequests;
@end

@implementation Viadeo

@synthesize clientID, accessToken, sessionID;

#pragma mark -
#pragma mark Init
- (id)initWithClientID:(NSString *)_clientID ClientSecret:(NSString *)_clientSecret Delegate:(id)_delegate
{
    self = [super init];
    if (self)
    {
        delegate = _delegate;
        
        self.clientID = _clientID;
        [Viadeo saveObject:_clientID forKey:@"ClientID"];
        
        clientSecret = [_clientSecret retain];
        [Viadeo saveObject:_clientSecret forKey:@"ClientSecret"];
        
        requestsArray = [[NSMutableArray alloc] init];
        
        self.accessToken = [Viadeo readAccessTokenForCliendID:self.clientID];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viadeoRequestDidFinish:) name:VD_REQUEST_DID_FINISH_LOADING object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viadeoRequestDidFinish:) name:VD_REQUEST_DID_FAIL_WITH_ERROR object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark Deallocation
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VD_REQUEST_DID_FINISH_LOADING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VD_REQUEST_DID_FAIL_WITH_ERROR object:nil];
    
    delegate = nil;
    
    self.clientID = nil;
    
    [clientSecret release];
    clientSecret = nil;
    
    [loginPopUp release];
    loginPopUp = nil;
    
    self.accessToken = self.sessionID = nil;
    
    [requestsArray release];
    requestsArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Object Methods
+ (NSString *)readObjectForKey:(NSString *)_key
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    return [_userDefaults valueForKey:_key];
}

+ (void)saveObject:(NSString *)_object forKey:(NSString *)_key
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    [_userDefaults setValue:_object forKey:_key];
    [_userDefaults synchronize];
}

+ (void)removeObjectForKey:(NSString *)_key
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    [_userDefaults removeObjectForKey:_key];
    [_userDefaults synchronize];
}

#pragma mark -
#pragma mark Access Token Methods
- (void)saveAccessToken:(NSString *)_accessToken forCliendID:(NSString *)_clientID
{
    self.clientID = _clientID;
    [Viadeo saveObject:_clientID forKey:@"ClientID"];
    
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    [_userDefaults setValue:_accessToken forKey:[@"" stringByAppendingFormat:@"%@.token", _clientID]];
    [_userDefaults synchronize];
    
    self.accessToken = _accessToken;
}

+ (NSString *)readAccessTokenForCliendID:(NSString *)_clientID
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    return [_userDefaults valueForKey:[@"" stringByAppendingFormat:@"%@.token", _clientID]];
}

+ (void)removeAccessTokenForClientID:(NSString *)_clientID
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    [_userDefaults removeObjectForKey:[@"" stringByAppendingFormat:@"%@.token", _clientID]];
    [_userDefaults synchronize];
}

#pragma mark -
#pragma mark Session ID Methods
- (void)saveSessionID:(NSString *)_session forCliendID:(NSString *)_clientID
{
    [Viadeo saveObject:_session forKey:[@"" stringByAppendingFormat:@"%@.sessionID", _clientID]];
    self.sessionID = _session;
}

+ (NSString *)readSessionIDForCliendID:(NSString *)_clientID
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    return [_userDefaults valueForKey:[@"" stringByAppendingFormat:@"%@.sessionID", _clientID]];
}

+ (void)removeSessionIDForClientID:(NSString *)_clientID
{
    NSUserDefaults *_userDefaults = [NSUserDefaults standardUserDefaults];
    [_userDefaults removeObjectForKey:[@"" stringByAppendingFormat:@"%@.sessionID", _clientID]];
    [_userDefaults synchronize];
}

#pragma mark -
#pragma mark Log Methods
+ (BOOL)isLoggedIn
{
    return [Viadeo readAccessTokenForCliendID:[Viadeo readObjectForKey:@"ClientID"]]? YES:NO;
}

- (void)logOut
{
    [Viadeo removeAccessTokenForClientID:clientID];
    [Viadeo removeObjectForKey:@"ClientID"];
    [Viadeo removeObjectForKey:@"ClientSecret"];
    [self cancelAllRequests];
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}

#pragma mark -
#pragma mark API Methods
#pragma mark Authorize Method
- (void)authorize
{
    if (clientID && clientSecret) {
        NSArray *_preferredLanguages = [NSLocale preferredLanguages];
        NSString *_lang = @"en";
        if (_preferredLanguages && _preferredLanguages.count > 0) {
            _lang = [_preferredLanguages objectAtIndex:0];
        }
        
        NSString *_url = [@"" stringByAppendingFormat:VD_AUTHORIZATION_URL_PARAMETERS, VD_AUTHORIZATION_URL, _lang, clientID, VD_REDIRECT_URL, VD_CANCEL_REDIRECT_URL];
        
        [loginPopUp release];
        loginPopUp = [[VDLoginPopUp alloc] initWithURL:_url ClientID:clientID ClientSecret:clientSecret Delegate:self];
        [loginPopUp show];
    } else if (delegate && [delegate respondsToSelector:@selector(viadeoConnectDidNotLogin:withError:)]) {
        NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:@"Invalid Client" forKey:NSLocalizedDescriptionKey];
        NSError *_error = [[NSError alloc] initWithDomain:VIADEO_API_ERROR code:-1 userInfo:_userInfo];
        [delegate viadeoConnectDidNotLogin:NO withError:_error];
        [_error release];
    }
}

#pragma mark Request Methods
- (VDRequest *)getRequestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andQuery:(NSDictionary *)_query andParams:(NSDictionary *)_params andUserInfo:(id)_userInfo andObject:(id)_object andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured
{
    VDRequest *_request = [[[VDRequest alloc] init] autorelease];
    _request.delegate = _delegate;
    _request.object = 
    _request.httpMethod = _httpMethod;
    _request.graphPath = _graphPath;
    _request.userInfo = _userInfo;
    _request.params = _params;
    _request.query = _query;
    _request.object = _object;
    
    if (!self.accessToken) {
        if (_delegate && [_delegate respondsToSelector:@selector(viadeoRequest:didFailWithError:)]) {
            NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:@"Access Token is nil" forKey:NSLocalizedDescriptionKey];
            NSError *_error = [[NSError alloc] initWithDomain:VIADEO_API_ERROR code:-1 userInfo:_userInfo];
            [_delegate viadeoRequest:_request didFailWithError:_error];
            [_error release];
        }
    } else {
        NSString *_requestPrefix = _isSecured ? @"https" : @"http";
        
        /* Only for #TESTS */
        #if VD_API == VD_MIDDLE_END_DEV
            _requestPrefix = @"http";
        #elif VD_API == VD_MIDDLE_END_PROD
            _requestPrefix = @"http";
        #elif VD_API == VD_API_DEV
            _requestPrefix = @"https";
        #elif VD_API == VD_API_PROD
            _requestPrefix = @"https";
        #endif
        /****/
        
        if ([_httpMethod isEqualToString:VD_HTTP_METHOD_GET]) {
            NSString *_httpURL = [@"" stringByAppendingFormat:VD_API_URL, _requestPrefix, VD_GET_ACCESS_TOKEN_PARAM];
            _httpURL = [@"" stringByAppendingFormat:_httpURL, _graphPath, VD_SERVER_TOKEN, self.accessToken];
            _httpURL = [_httpURL stringByAppendingString:[VDRequest getQuery:_query]];
            _request.httpURL = _httpURL;
            _request.body = nil;
        } else {
            NSString *_httpURL = [@"" stringByAppendingFormat:VD_API_URL, _requestPrefix, VD_GET_ACCESS_TOKEN_PARAM];
            _httpURL = [@"" stringByAppendingFormat:_httpURL, _graphPath, VD_SERVER_TOKEN, self.accessToken];
            _request.httpURL = _httpURL;
            [_request insertBody:_params withAccessToken:nil];
        }
        
        if (self.sessionID && self.sessionID.length > 0) { _request.httpURL = [_request.httpURL stringByAppendingFormat:@"&sessionID=%@", self.sessionID]; }
        
        return _request;
    }
    
    return nil;
}

- (BOOL)requestExists:(VDRequest *)_request
{
    for (VDRequest *_rq in requestsArray) {
        if ([_rq isEqualToRequest:_request]) {
            return YES;
        }
    }
    return NO;
}

- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andQuery:(NSDictionary *)_query andParams:(NSDictionary *)_params andUserInfo:(id)_userInfo andObject:(id)_object andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured
{
    VDRequest *_request = [self getRequestWithHttpMethod:_httpMethod andGraphPath:_graphPath andQuery:_query andParams:_params andUserInfo:_userInfo andObject:_object andDelegate:_delegate isExclusive:_isExclusive andSecured:_isSecured];
    if (!_request) { return nil; }
    
    if (!_isExclusive || (_isExclusive && ![self requestExists:_request])) {
        [requestsArray addObject:_request];
        [_request sendWithBody:_request.body isZipped:YES];
        return _request;
    } else {
        VDLog(@"[%@] The following request is already launched: %@", self.class, _request.httpURL);
    }
    
    return nil;
}

- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andParams:(NSDictionary *)_params andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured
{
    VDRequest *_request = [self getRequestWithHttpMethod:_httpMethod andGraphPath:_graphPath andQuery:nil andParams:_params andUserInfo:nil andObject:nil andDelegate:_delegate isExclusive:_isExclusive andSecured:_isSecured];
    [requestsArray addObject:_request];
    [_request sendWithBody:_request.body isZipped:YES];
    return _request;
}

- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured
{
    return [self requestWithHttpMethod:_httpMethod andGraphPath:_graphPath andParams:nil andDelegate:_delegate isExclusive:_isExclusive andSecured:_isSecured];
}

- (VDRequest *)requestWithHttpMethod:(NSString *)_httpMethod andGraphPath:(NSString *)_graphPath andQuery:(NSDictionary *)_query andDelegate:(id)_delegate isExclusive:(BOOL)_isExclusive andSecured:(BOOL)_isSecured
{
    VDRequest *_request = [self getRequestWithHttpMethod:_httpMethod andGraphPath:_graphPath andQuery:_query andParams:nil andUserInfo:nil andObject:nil andDelegate:_delegate isExclusive:_isExclusive andSecured:_isSecured];
    [requestsArray addObject:_request];
    [_request sendWithBody:_request.body isZipped:YES];
    return _request;
}

- (NSArray *)requestsForObject:(id)_object
{
    NSMutableArray *_requests = [NSMutableArray array];
    
    for (int i=0; i < requestsArray.count; i++) {
        VDRequest *_request = [requestsArray objectAtIndex:i];
        if ([_request.object isEqual:_object]) {
            [_requests addObject:_request];
        }
    }
    return _requests;
}

#pragma mark -
#pragma mark Cancel Methods
- (void)cancelAllRequests
{
    for (int i=0; i < requestsArray.count; i++) {
        VDRequest *_request = [requestsArray objectAtIndex:i];
        _request.delegate = nil;
        _request.object = nil;
        [_request cancel];
        [requestsArray removeObject:_request];
        i -= 1;
    }
}

- (void)cancelRequestsForObject:(id)_object
{
    for (int i=0; i < requestsArray.count; i++) {
        VDRequest *_request = [requestsArray objectAtIndex:i];
        if ([_request.object isEqual:_object]) {
            _request.delegate = nil;
            _request.object = nil;
            [_request cancel];
            [requestsArray removeObject:_request];
            i -= 1;
        }
    }
}

- (void)cancelRequestsForGraphPath:(NSString *)_graphPath
{
    for (int i=0; i < requestsArray.count; i++) {
        VDRequest *_request = [requestsArray objectAtIndex:i];
        if ([_request.graphPath isEqualToString:_graphPath]) {
            _request.delegate = nil;
            _request.object = nil;
            [_request cancel];
            [requestsArray removeObject:_request];
            i -= 1;
        }
    }
}

#pragma mark -
#pragma mark Viadeo PopUp Callbacks
- (void)viadeoPopUpDidLogin:(NSString *)_accessToken
{
    [self saveAccessToken:_accessToken forCliendID:clientID];
    
    [loginPopUp dismiss:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(viadeoConnectDidLogin:)]) {
        [delegate viadeoConnectDidLogin:_accessToken];
    }
}

- (void)viadeoPopUpDidNotLogin:(BOOL)_canceled withError:(NSError *)_error
{
    [loginPopUp dismiss:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(viadeoConnectDidNotLogin:withError:)]) {
        [delegate viadeoConnectDidNotLogin:_canceled withError:_error];
    }
}

#pragma mark -
#pragma mark Viadeo Viadeo Request Notification
- (void)viadeoRequestDidFinish:(NSNotification *)_notification
{
    VDRequest *_request = _notification.object;
    _request.delegate = nil;
    //_request.object = nil;
    [requestsArray removeObject:_request];
}

@end
