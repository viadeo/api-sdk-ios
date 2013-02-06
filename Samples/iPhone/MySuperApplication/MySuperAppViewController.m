//
//  MySuperAppViewController.m
//  MySuperApplication
//
//  Created by Viadeo on 19/09/11.
//  Copyright (c) 2011 Viadeo. All rights reserved.
//

#import "MySuperAppViewController.h"

#define VD_CLIENT_ID @"CLIENT_ID"
#define VD_CLIENT_SECRET @"CLIENT_SECRET"

@implementation MySuperAppViewController

@synthesize viadeo;
@synthesize logInButton, logOutButton, getMyProfileButton, postButton, putButton, deleteButton;

#pragma mark -
#pragma mark View Callbacks
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [logInButton setTitle:NSLocalizedString(@"VD_WINDOW_LOGIN_BUTTON", @"") forState:UIControlStateNormal];
    [logOutButton setTitle:NSLocalizedString(@"VD_WINDOW_LOGOUT_BUTTON", @"") forState:UIControlStateNormal];
    [getMyProfileButton setTitle:NSLocalizedString(@"VD_WINDOW_GET_MY_PROFILE_BUTTON", @"") forState:UIControlStateNormal];
}

- (void)releaseOutlets
{
    self.logInButton = nil;
    self.logOutButton = nil;
    self.getMyProfileButton = nil;
    self.postButton = nil;
    self.putButton = nil;
}

- (void)viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Deallocation
- (void)dealloc
{
    self.viadeo = nil;
    [self releaseOutlets];
    [super dealloc];
}

#pragma mark -
#pragma mark Buttons Callbacks
- (IBAction)selectLogInButton
{
    if (!viadeo) {
        viadeo = [[Viadeo alloc] initWithClientID:VD_CLIENT_ID ClientSecret:VD_CLIENT_SECRET Delegate:self];
    }
    
    //Already logged in
    if ([Viadeo isLoggedIn]) {
        logInButton.hidden = YES;
        getMyProfileButton.hidden = postButton.hidden = putButton.hidden = deleteButton.hidden = logOutButton.hidden = NO;
        
        UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VD_ALERT_VIEW_LOGGED_IN", @"") message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"VD_ALERT_VIEW_CLOSE", @"") otherButtonTitles: nil];
        [_alertView show];
        [_alertView release];
    }
    //Request authorization
    else {
        [viadeo authorize];
    }
}

- (IBAction)selectLogOutButton
{
    logInButton.hidden = NO;
    getMyProfileButton.hidden = postButton.hidden = putButton.hidden = deleteButton.hidden = logOutButton.hidden = YES;
    
    [viadeo logOut];
    
    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VD_ALERT_VIEW_LOGGED_OUT", @"") message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"VD_ALERT_VIEW_CLOSE", @"") otherButtonTitles: nil];
    [_alertView show];
    [_alertView release];
}

- (IBAction)selectGetMyProfileButton
{
    // GET me
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me" andDelegate:self isExclusive:YES andSecured:YES];
}

- (IBAction)selectPostButton
{
    // POST me/career
    NSMutableDictionary *_careerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Metacortex", @"company", @"Level Designer", @"position", [NSNumber numberWithInt:2004], @"from", [NSNumber numberWithInt:2005], @"to", @"High Tech", @"company_industry", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_POST andGraphPath:@"me/career" andParams:_careerParams andDelegate:self isExclusive:YES andSecured:YES];
}

- (IBAction)selectPutButton
{
    // PUT me
    NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"iOS, Android, Blackberry, Windows Phone, Bada", @"headline", @"Software Engineer", @"introduction", @"Football, Cinema", @"interests", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_PUT andGraphPath:@"me" andParams:_params andDelegate:self isExclusive:YES andSecured:YES];
}

- (IBAction)selectDeleteButton
{
    // DELETE me/tags
    // Set value to contact_id
    NSMutableDictionary *_tagParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"friends", @"tag", @"...", @"contact_id", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_DELETE andGraphPath:@"me/tags" andParams:_tagParams andDelegate:self isExclusive:YES andSecured:YES];
}

#pragma mark -
#pragma mark Viadeo Connect Log In Callbacks
- (void)viadeoConnectDidLogin:(NSString *)_accessToken
{
    logInButton.hidden = YES;
    getMyProfileButton.hidden = postButton.hidden = putButton.hidden = deleteButton.hidden = logOutButton.hidden = NO;
    
    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VD_ALERT_VIEW_LOGGED_IN", @"") message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"VD_ALERT_VIEW_CLOSE", @"") otherButtonTitles: nil];
    [_alertView show];
    [_alertView release];
}

- (void)viadeoConnectDidNotLogin:(BOOL)_cancelled withError:(NSError *)_error
{
    if (_cancelled) return;
    
    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VD_ALERT_VIEW_LOGIN_ERROR_TITLE", @"") message:[_error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"VD_ALERT_VIEW_CLOSE", @"") otherButtonTitles: nil];
    [_alertView show];
    [_alertView release];
}

#pragma mark -
#pragma mark Viadeo Request Callbacks
- (void)viadeoRequest:(VDRequest *)_request didLoadDictionary:(NSDictionary *)_dictionary
{
    // More informations about Viadeo API here:
    // http://dev.viadeo.com/documentation/api-documentation/
    
    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:[@"" stringByAppendingFormat:@"%@ %@", _request.httpMethod, _request.graphPath] message:[_dictionary description] delegate:nil cancelButtonTitle:NSLocalizedString(@"VD_ALERT_VIEW_CLOSE", @"") otherButtonTitles: nil];
    [_alertView show];
    [_alertView release];
}

- (void)viadeoRequest:(VDRequest *)_request didFailWithError:(NSError *)_error
{
    // Error Code == -1001: Time out
    // Error Message: The request timed out.
    
    // Error Code == -1009: Offline status
    // Error Message: The Internet connection appears to be offline.
    
    // API Errors
    // Error Code == -1
    
    // Error Domain: ViadeoAPIError
    // Error Message: Access violation - you're not authorized to access this resource.
    
    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:_error.domain message:[_error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"VD_ALERT_VIEW_CLOSE", @"") otherButtonTitles: nil];
    [_alertView show];
    [_alertView release];
}

@end
