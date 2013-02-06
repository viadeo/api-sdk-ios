//
//  VDLoginPopUp.m
//  MySuperApplication
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import "VDLoginPopUp.h"
#import "VDConstants.h"
#import "JSONKit.h"

@implementation VDLoginPopUp

#pragma mark -
#pragma mark Init
- (id)initWithURL:(NSString *)_webPageURL ClientID:(NSString *)_clientID ClientSecret:(NSString *)_clientSecret Delegate:(id)_delegate
{
    self = [super init];
    if (self) {
        loginDelegate = _delegate;
        webPageURL = [_webPageURL retain];
        clientID = [_clientID retain];
        clientSecret = [_clientSecret retain];
        titleLabel.text = NSLocalizedString(@"VD_POPUP_TITLE", @"");
    }
    return self;
}

#pragma mark -
#pragma mark Deallocation
- (void)dealloc
{
    loginDelegate = nil;
    
    [clientID release];
    clientID = nil;
    
    [clientSecret release];
    clientSecret = nil;
    
    [urlConnection release];
    urlConnection = nil;
    
    [receivedData release];
    receivedData = nil;
    
    [super dealloc];
}

#pragma mark-
#pragma mark API Methods
- (void)getAccessToken:(NSString *)_code
{
    VDLog(@"%@", VD_GET_ACCESS_TOKEN_URL);
    
    NSURL *_url = [NSURL URLWithString:VD_GET_ACCESS_TOKEN_URL];
    
    NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:VD_LOGIN_POPUP_AUTHORIZATION_TIME_OUT];
    [_request setHTTPMethod:VD_HTTP_METHOD_POST];
    [_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *_body = [@"" stringByAppendingFormat:@"grant_type=authorization_code&client_id=%@&client_secret=%@&redirect_uri=%@&code=%@", clientID, clientSecret, VD_REDIRECT_URL, _code];
    [_request setHTTPBody:[_body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urlConnection release];
    urlConnection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
    if (urlConnection) {
		[receivedData release];
		receivedData = [[NSMutableData data] retain];
	}
}

#pragma mark -
#pragma mark Web View Callbacks
- (BOOL)webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *_absoluteRequest = [[request URL] absoluteString];
    
    VDLog(@"%@", _absoluteRequest);
    
    // Accept
    if ([_absoluteRequest isEqualToString:VD_AUTHORIZATION_URL]) {
        [spinner startAnimating];
    }
    // Redirection
    else if ([_absoluteRequest hasPrefix:[@"" stringByAppendingFormat:@"%@/?code=", VD_REDIRECT_URL]]) {
        // No need to load the redirection page
        // The URL http://www.viadeo-connect.com is only used as a an identifier
        [_webView stopLoading];
        _webView.delegate = nil;
        
        NSRange _range = [_absoluteRequest rangeOfString:@"?code="];
        if (_range.length == [@"?code=" length])
        {
            NSString *_code = [_absoluteRequest substringFromIndex:_range.location + _range.length];
            VDLog(@"Code: %@", _code);
            [self getAccessToken:_code];
        }
    }
    // Cancel
    else if ([_absoluteRequest hasPrefix:VD_CANCEL_REDIRECT_URL]) {
         // No need to load the redirection page
         // The URL http://www.viadeo-connect.com/cancel is only used as a an identifier
         [_webView stopLoading];
         _webView.delegate = nil;
         
         if (loginDelegate && [loginDelegate respondsToSelector:@selector(viadeoPopUpDidNotLogin:withError:)]) {
             [loginDelegate viadeoPopUpDidNotLogin:YES withError:nil];
         }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [spinner stopAnimating];
    spinner.hidden = YES;
    
    [self updateWebViewOrientation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)_error
{
    VDLog(@"Web View Error: Code %d | %@ | %@ | %@", _error.code, _error.domain, _error.localizedDescription, _error.localizedFailureReason);
    
    if (loginDelegate && [loginDelegate respondsToSelector:@selector(viadeoPopUpDidNotLogin:withError:)])
    {
        [loginDelegate viadeoPopUpDidNotLogin:NO withError:_error];
    }
}

#pragma mark -
#pragma mark URL Connection Callbacks
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [urlConnection release];
    urlConnection = nil;
    
    if (receivedData && receivedData.length > 0) {
        NSString *_response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        VDLog(@"URL Connection Response: %@", _response);
        [_response release];
        _response = nil;
        
        JSONDecoder *_jsonDecoder = [[JSONDecoder alloc] init];
        NSDictionary *_dictionary = [_jsonDecoder objectWithData:receivedData error:nil];
        [_jsonDecoder release];
        
        [receivedData release];
        receivedData = nil;
        
        if ([_dictionary objectForKey:@"error"]) {
            NSString *_errorMessage = [_dictionary objectForKey:@"error"];
            
            NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:_errorMessage forKey:NSLocalizedDescriptionKey];
            NSError *_error = [[NSError alloc] initWithDomain:@"ViadeoAPILoginError" code:-1 userInfo:_userInfo];
            if (_error && loginDelegate && [loginDelegate respondsToSelector:@selector(viadeoPopUpDidNotLogin:withError:)])
            {
                [loginDelegate viadeoPopUpDidNotLogin:NO withError:_error];
            }
            [_error release];
            return;
        } else {
            NSString *_accessToken = [_dictionary objectForKey:VD_SERVER_TOKEN];
            if (_accessToken && loginDelegate && [loginDelegate respondsToSelector:@selector(viadeoPopUpDidLogin:)])
            {
                VDLog(@"Access Token: %@", _accessToken);
                [loginDelegate viadeoPopUpDidLogin:_accessToken];
                return;
            }
        }
    }
    
    if (loginDelegate && [loginDelegate respondsToSelector:@selector(viadeoPopUpDidNotLogin:withError:)]) {
        [loginDelegate viadeoPopUpDidNotLogin:NO withError:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)_error
{
    VDLog(@"URL Connection Error: Code %d | %@ | %@ | %@", _error.code, _error.domain, _error.localizedDescription, _error.localizedFailureReason);
    
    [urlConnection release];
    urlConnection = nil;
    
    [receivedData release];
    receivedData = nil;
    
    if (loginDelegate && [loginDelegate respondsToSelector:@selector(viadeoPopUpDidNotLogin:withError:)])
    {
        [loginDelegate viadeoPopUpDidNotLogin:NO withError:_error];
    }
}

@end
