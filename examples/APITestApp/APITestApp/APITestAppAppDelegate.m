//
//  APITestAppAppDelegate.m
//  APITestApp
//
//  Created by Viadeo on 22/09/11.
//  Copyright (c) 2011 Viadeo. All rights reserved.
//

#import "APITestAppAppDelegate.h"

#error Include your Viadeo client ID and secret below and then remove this line to get rid of this error

#define VD_CLIENT_ID @"CLIENT_ID"
#define VD_CLIENT_SECRET @"CLIENT_SECRET"
#define VD_MY_ACCESS_TOKEN @"MY_ACCESS_TOKEN"

@implementation APITestAppAppDelegate

@synthesize window = _window, viadeo;

#pragma mark -
#pragma mark Viadeo Request Callbacks
- (void)viadeoRequest:(VDRequest *)_request didLoad:(NSDictionary *)_dictionary
{
    // More informations about Viadeo API here:
    // http://dev.viadeo.com/documentation/api-documentation/
    
    NSLog(@"%@ %@ | %@", _request.httpMethod, _request.graphPath, [_dictionary description]);
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
    
    NSLog(@"%@ | %@", _error.domain, [_error localizedDescription]);
}

#pragma mark -
#pragma mark Deallocation
- (void)dealloc
{
    self.viadeo = nil;
    [_window release];
    [super dealloc];
}

#pragma mark -
#pragma mark Application Callbacks
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    viadeo = [[Viadeo alloc] initWithClientID:VD_CLIENT_ID ClientSecret:VD_CLIENT_SECRET Delegate:self];
    [viadeo setAccessToken:VD_MY_ACCESS_TOKEN];
    
    // GET me
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me" andDelegate:self isExclusive:YES andSecured:YES];
    
    // GET me/tags
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me/tags" andDelegate:self isExclusive:YES andSecured:YES];
    
    // GET me in english language
    NSMutableDictionary *_query = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"en", @"language", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me" andQuery:_query andDelegate:self isExclusive:YES andSecured:YES];
    
    // GET me/contacts
    _query = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:50], @"limit", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me/contacts" andQuery:_query andDelegate:self isExclusive:YES andSecured:YES];
    
    // GET me/visits => only for Level 3 users
    _query = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3], @"limit", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me/visits" andQuery:_query andDelegate:self isExclusive:YES andSecured:YES];
    
    // POST status
    NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"hello from iOS Viadeo SDK", @"message", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_POST andGraphPath:@"status" andParams:_params andDelegate:self isExclusive:YES andSecured:YES];
    
    // POST me/tags
    NSMutableDictionary *_tagParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"friends", @"tag", @"scmeiywVlzpaOdarioErkuvkao", @"contact_id", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_POST andGraphPath:@"me/tags" andParams:_tagParams andDelegate:self isExclusive:YES andSecured:YES];
    
    // POST me/career
    NSMutableDictionary *_careerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Nintendo", @"company", @"Level Designer", @"position", [NSNumber numberWithInt:2004], @"from", [NSNumber numberWithInt:2005], @"to", @"High Tech", @"company_industry", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_POST andGraphPath:@"me/career" andParams:_careerParams andDelegate:self isExclusive:YES andSecured:YES];
    
    // PUT me
    _params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Viadeo | Newton Corp Co-Founder, Freelancer, Viadeo iOS Lead Developer", @"headline", @"Viadeo | iPhone, iPad, Réalité Augmentée, Google Maps, Mappy SDK, Conception/Développement Mobilité, Architecture Clients/Serveurs, Base de Données, Réseaux IP, Cisco Wireless Network \
                                    \
                                    Niveaux d’intervention :\
                                    \
                                    •	Conception et Développement logiciel\
                                    •	Réalisation d'applications sur iPhone et iPad - Orange, Pages Jaunes\
                                    •	Documentation : Fonctionnelle, Technique et Utilisateur\
                                    •	Environnement IP (IP Phones, softphone, SIP)\
                                    •	Systèmes d’exploitation : Windows, Linux, MAC OS X\
                                    •	Administration serveurs\
                                    •	Architecture n-tiers\
                                    •	Architecture Serveurs/Mobiles (Cisco Wireless Lan Controller, Cisco Location Appliance, Cisco Wireless Control System)\
                                    \
                                    Technologies connues :\
                                    \
                                    •	Systèmes d’exploitation : 	iPhone OS, Mac OS X, Unix/Linux/Solaris, Windows 9x/2000/XP/Pocket PC/Vista/Server 2003\
                                    \
                                    •	Compétences :	Objective C, Java/J2EE, JDBC, Servlet, JSP, C, C++, PHP, Javascript, SOAP, SQL, UML, XML, HTML, Scripts Shell Unix, Cryptage, TCP/IP, SIP, VoIP, Skype SDK, Administration de Systèmes Unix\
                                    \
                                    •	Outils :	Visual Studio 6.0, Visual Net 2003, Microsoft embedded Visual C++ 4, Visual Studio 2005, Eclipse, MySQL, Sybase, Oracle, Ethereal, Tomcat, Apache, Gdb, Cervisia, Bugzilla, XCode, KDevelop, Darwin Streaming Server", @"introduction", @"Viadeo | Football, Cinema", @"interests", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_PUT andGraphPath:@"me" andParams:_params andDelegate:self isExclusive:YES andSecured:YES];
    
    // DELETE me/tags
    _tagParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"friends", @"tag", @"scmeiywVlzpaOdarioErkuvkao", @"contact_id", nil];
    [viadeo requestWithHttpMethod:VD_HTTP_METHOD_DELETE andGraphPath:@"me/tags" andParams:_tagParams andDelegate:self isExclusive:YES andSecured:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
