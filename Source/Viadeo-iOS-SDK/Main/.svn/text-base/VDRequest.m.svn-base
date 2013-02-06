//
//  VDRequest.m
//  MySuperApplication
//
//  Created by Viadeo on 31/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import "VDRequest.h"
#import "JSONKit.h"
#import "VDConstants.h"

#define VD_CONTENT_TYPE_APPLICATION_JSON @"application/json"
#define VD_CONTENT_TYPE_IMAGE @"image"

@implementation VDRequest

@synthesize isWaitingForResponse, isDownloading, isCancelled;
@synthesize delegate, object;
@synthesize header, httpURL, httpMethod, graphPath, body, userInfo, params, query, receivedData, urlResponse, retryCount;

#pragma mark -
#pragma mark Init
- (id)init
{
    self = [super init];
    if (self) {
        enabledLogs = NO;
        enabledErrorLogs = NO;
        isWaitingForResponse = isDownloading = isCancelled = NO;
        retryCount = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancel) name:VD_REQUEST_CANCEL object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark Deallocation
- (void)releaseConnection
{
    [urlConnection release];
    urlConnection = nil;
    self.receivedData = nil;
    self.urlResponse = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VD_REQUEST_CANCEL object:nil];
    
    [readJsonFileThread cancel];
    [readJsonFileThread release];
    readJsonFileThread = nil;
    
    self.delegate = nil;
    self.object = nil;
    
    [urlConnection cancel];
    [self releaseConnection];
    
    self.httpURL = nil;
    self.httpMethod = nil;
    self.graphPath = nil;
    self.body = nil;
    self.userInfo = nil;
    self.params = nil;
    self.query = nil;
    self.header = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Utils Methods
- (void)sendFinishNotification
{
    NSMutableDictionary *_dictionary = [NSMutableDictionary dictionary];
    if (self.receivedData) { [_dictionary setObject:self.receivedData forKey:@"data"]; }
    if (urlResponse) { [_dictionary setObject:urlResponse forKey:@"response"]; }
    [[NSNotificationCenter defaultCenter] postNotificationName:VD_REQUEST_DID_FINISH_LOADING object:self userInfo:_dictionary];
}

- (BOOL)isEqualToRequest:(VDRequest *)_request
{
    if ([self.httpMethod isEqualToString:VD_HTTP_METHOD_GET] && [self.httpURL isEqualToString:_request.httpURL]) {
        return YES;
    } else if ([self.httpURL isEqualToString:_request.httpURL] && [self.body isEqualToString:_request.body]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Query Method
+ (NSString *)getQuery:(NSDictionary *)_query
{
    NSString *_httpQuery = @"";
    for (NSString *_key in _query) {
        NSString *_value = @"";
        id _object = [_query objectForKey:_key];
        if ([_object isKindOfClass:[NSNumber class]]) {
            _value = [[_object stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            _value = [_object stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        _httpQuery = [_httpQuery stringByAppendingFormat:@"&%@=%@", _key, _value];
    }
    return _httpQuery;
}

#pragma mark -
#pragma mark Body Methods
+ (NSString *)getBody:(NSDictionary *)_params withAccessToken:(NSString *)_accessToken
{
    NSString *_bodyString = _accessToken && _accessToken.length > 0 ? [@"" stringByAppendingFormat:@"%@=%@", VD_SERVER_TOKEN, _accessToken] : nil;
    for (NSString *_key in _params) {
        NSString *_value = @"";
        id _object = [_params objectForKey:_key];
        
        if ([_object isKindOfClass:[NSNumber class]]) {
            _value = [[_object stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            _value = [_object stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        _bodyString = _bodyString ? [_bodyString stringByAppendingFormat:@"&%@=%@", _key, _value] : [@"" stringByAppendingFormat:@"%@=%@", _key, _value];
    }
    return _bodyString;
}

- (void)insertBody:(NSDictionary *)_params withAccessToken:(NSString *)_accessToken
{
    self.body = [VDRequest getBody:_params withAccessToken:_accessToken];
}

#pragma mark -
#pragma mark Send Methods
- (void)sendWithBody:(NSString *)_body isZipped:(BOOL)_isZipped
{
    isWaitingForResponse = YES;
    isCancelled = NO;
    
    if (enabledLogs) {
        VDLog(@"[%@] %@ %@", [self class], self.httpMethod, self.httpURL);
        if (_body) { VDLog(@"[%@] %@", [self class], _body); }
    }
    
    NSURL *_url = [NSURL URLWithString:self.httpURL];
    
    NSMutableURLRequest *_urlRequest = [NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:VD_REQUEST_TIME_OUT];
    [_urlRequest setHTTPMethod:self.httpMethod];
    
    if (![self.httpMethod isEqualToString:VD_HTTP_METHOD_GET]) {
        [_urlRequest setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    }
    
    if (_isZipped) {
        [_urlRequest setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    }
    
    for (NSString *_key in self.header) {
        [_urlRequest setValue:[self.header objectForKey:_key] forHTTPHeaderField:_key];
    }
    
    if (enabledLogs) { VDLog(@"Request Header: %@", [_urlRequest allHTTPHeaderFields]); }
    
    if (_body) { _urlRequest.HTTPBody = [_body dataUsingEncoding:NSUTF8StringEncoding]; }
    
    [urlConnection release];
    urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
    if (urlConnection) {
		[receivedData release];
		receivedData = [[NSMutableData data] retain];
	}
}

- (void)send
{
    [self sendWithBody:nil isZipped:NO];
}

#pragma mark -
#pragma mark Cancel Method
- (void)cancel
{
    self.delegate = nil;
    self.object = nil;
    isCancelled = YES;
    
    [urlConnection cancel];
    [self releaseConnection];
    
    [readJsonFileThread cancel];
    [readJsonFileThread release];
    readJsonFileThread = nil;
    
    if (enabledErrorLogs) {
        VDLog(@"[%@] %@ is Cancelled: %@", self.class, self, self.httpURL);
    }
}

#pragma mark -
#pragma mark JSON Methods
- (void)insertJSONDictionary:(NSDictionary *)_dictionary
{
    if (!readJsonFileThread || (readJsonFileThread && ([readJsonFileThread isCancelled] || [readJsonFileThread isFinished]))) { return; }
    
    if ([_dictionary objectForKey:@"error"]) { // Error in a JSON Dictionary
        NSDictionary *_errorDictionary = [_dictionary objectForKey:@"error"];
        NSArray *_messageArray = [_errorDictionary objectForKey:@"message"];
        NSString *_message = @"";
        if (_messageArray && _messageArray.count > 0) {
            _message = [_messageArray objectAtIndex:0];
        }
        
        NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:_message forKey:NSLocalizedDescriptionKey];
        NSError *_error = [[NSError alloc] initWithDomain:VIADEO_API_ERROR code:-1 userInfo:_userInfo];
        if (readJsonFileThread && delegate && [delegate respondsToSelector:@selector(viadeoRequest:didFailWithError:)]) {
            [delegate viadeoRequest:self didFailWithError:_error];
        }
        [_error release];
    } else if ([_dictionary objectForKey:@"photos"]) { // Photos Group stored in a JSON Dictionary
        NSArray *_photos = [[_dictionary objectForKey:@"photos"] objectForKey:@"photo"];
        [[NSNotificationCenter defaultCenter] postNotificationName:VD_REQUEST_DID_FINISH_LOADING object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_photos, @"photos", nil]];
        [self releaseConnection];
        return;
    } else {
        if (readJsonFileThread && _dictionary && delegate && [delegate respondsToSelector:@selector(viadeoRequest:didLoadDictionary:)]) { // Response in a JSON Dictionary
            [delegate viadeoRequest:self didLoadDictionary:_dictionary];
        } else if (readJsonFileThread && !_dictionary && delegate && [delegate respondsToSelector:@selector(viadeoRequest:didLoadDictionary:)]) { // No JSON Dictionary
            if (receivedData && [receivedData length] > 0) {
                NSString *_message = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                [delegate viadeoRequest:self didLoadDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[(NSHTTPURLResponse *)urlResponse statusCode]], @"code", _message, @"result", nil]];
                [_message release];
            } else if (urlResponse) {
                NSString *_message = [NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse *)urlResponse statusCode]];
                [delegate viadeoRequest:self didLoadDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[(NSHTTPURLResponse *)urlResponse statusCode]], @"code", _message, @"result", nil]];
            }
        }
    }
    
    [self sendFinishNotification];
    [self releaseConnection];
}

- (void)readJSON:(NSObject *)_object
{
    NSAutoreleasePool *_pool = [[NSAutoreleasePool alloc] init];
    
    if ([[NSThread currentThread] isCancelled] || [[NSThread currentThread] isFinished] ) { [_pool drain]; return; }
    
    JSONDecoder *_jsonDecoder = [[JSONDecoder alloc] init];
    NSDictionary *_dictionary = [_jsonDecoder objectWithData:self.receivedData error:nil];
    [_jsonDecoder release];
    
    if ([[NSThread currentThread] isCancelled] || [[NSThread currentThread] isFinished] ) { [_pool drain]; return; }
    
    if (!_dictionary) {
        NSString *_response = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        VDLog(@"[%@] readJSON | _dictionary is nil!", [self class]);
        VDLog(@"[%@] %@", [self class], _response);
        [_response release];
        _response = nil;
    }
    
    if ([[NSThread currentThread] isCancelled] || [[NSThread currentThread] isFinished] ) { [_pool drain]; return; }
    
    [self performSelectorOnMainThread:@selector(insertJSONDictionary:) withObject:_dictionary waitUntilDone:YES];
    
    [_pool drain];
}

#pragma mark -
#pragma mark URL Connection Callbacks
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response
{
    isWaitingForResponse = NO;
    isDownloading = YES;
    
    //if (enabledLogs) { VDLog(@"[%@] didReceiveResponse: %@", [self class], _response); }
    
    if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
        self.urlResponse = _response;
        
        if (enabledLogs) {
            VDLog(@"[%@] Response Header: %@", [self class], [(NSHTTPURLResponse *)_response allHeaderFields]);
            VDLog(@"[%@] Response Content-Length: %d", [self class], [[[(NSHTTPURLResponse *)urlResponse allHeaderFields] objectForKey:@"Content-Length"] intValue]);
            VDLog(@"[%@] statusCode: %d", [self class], [(NSHTTPURLResponse *)_response statusCode]);
            VDLog(@"[%@] localizedStringForStatusCode: %@", [self class], [NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse *)_response statusCode]]);
        }
    }
    
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VD_REQUEST_WILL_FINISH_LOADING object:nil];
    
    isWaitingForResponse = isDownloading = NO;
    if (!isCancelled) {
        NSString *_contentType = [[(NSHTTPURLResponse *)urlResponse allHeaderFields] objectForKey:@"Content-Type"];
        
        if (enabledLogs) { VDLog(@"[%@] connectionDidFinishLoading | URL: %@", [self class], self.httpURL); }
        
        if (receivedData && _contentType && [_contentType hasPrefix:VD_CONTENT_TYPE_APPLICATION_JSON]) { // The received data is a JSON File
            
//            const char *_response = "{error:{message:[]}}";
//            self.receivedData = [NSData dataWithBytes:_response length:strlen(_response)]; // Test
            
            if (enabledLogs) {
                NSString *_jsonResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                VDLog(@"[%@] connectionDidFinishLoading: %@", [self class], _jsonResponse);
                [_jsonResponse release];
            }
            
            [readJsonFileThread cancel];
            [readJsonFileThread release];
            readJsonFileThread = [[NSThread alloc] initWithTarget:self selector:@selector(readJSON:) object:nil];
            [readJsonFileThread start];
        } else if (receivedData && _contentType && [_contentType hasPrefix:VD_CONTENT_TYPE_IMAGE]) { // The received data is an Image File
            //int _expectedLength = [[[(NSHTTPURLResponse *)urlResponse allHeaderFields] objectForKey:@"Content-Length"] intValue];
            
            if (/*_expectedLength == receivedData.length*/YES) { // Check if the image is valid
                if (self.delegate && [self.delegate respondsToSelector:@selector(viadeoRequest:didLoadImageData:fromCache:)]) {
                    [self.delegate viadeoRequest:self didLoadImageData:receivedData fromCache:NO];
                }
                [self sendFinishNotification];
            } else { // The image is not valid
                if (enabledErrorLogs) { VDLog(@"[%@] The image data is not valid", self.class); }
                if (delegate && [delegate respondsToSelector:@selector(viadeoRequest:didFailWithError:)]) {
                    NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:@"The image data is not valid" forKey:NSLocalizedDescriptionKey];
                    NSError *_error = [[NSError alloc] initWithDomain:VIADEO_API_ERROR code:-1 userInfo:_userInfo];
                    [delegate viadeoRequest:self didFailWithError:_error];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:VD_REQUEST_DID_FAIL_WITH_ERROR object:self];
            }
            [self releaseConnection];
        } else { // Not Recognized File
            if (delegate && [delegate respondsToSelector:@selector(viadeoRequest:didFailWithError:)]) {
                NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:[NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse *)urlResponse statusCode]] forKey:NSLocalizedDescriptionKey];
                NSError *_error = [[NSError alloc] initWithDomain:VIADEO_API_ERROR code:-1 userInfo:_userInfo];
                [delegate viadeoRequest:self didFailWithError:_error];
            }
            
            [self sendFinishNotification];
            [self releaseConnection];
        }
    } else { // The Request has been cancelled
        [self releaseConnection];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)_error
{
    isWaitingForResponse = isDownloading = NO;
    if (!isCancelled) {
        if (enabledErrorLogs) { VDLog(@"[%@] URL Connection Error: Code %d | %@ | %@ | %@", [self class], _error.code, _error.domain, _error.localizedDescription, _error.localizedFailureReason); }
        
        if (delegate && [delegate respondsToSelector:@selector(viadeoRequest:didFailWithError:)]) { [delegate viadeoRequest:self didFailWithError:_error]; }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VD_REQUEST_DID_FAIL_WITH_ERROR object:self];
    }
    [self releaseConnection];
}

@end
