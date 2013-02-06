//
//  MySuperApplication_iPadAppDelegate.m
//  MySuperApplication_iPad
//
//  Created by Viadeo on 20/09/11.
//  Copyright (c) 2011 Viadeo. All rights reserved.
//

#import "MySuperApplication_iPadAppDelegate.h"
#import "MySuperAppViewController_iPad.h"

@implementation MySuperApplication_iPadAppDelegate

@synthesize window = _window, navigationController;

#pragma mark -
#pragma mark Deallocation
- (void)dealloc
{
    self.navigationController = nil;
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
    
    MySuperAppViewController_iPad *_rootViewController = [[MySuperAppViewController_iPad alloc] initWithNibName:@"MySuperAppViewController_iPad" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
    _rootViewController.navigationItem.title = @"My Super App";
    [_rootViewController release];
    [self.window addSubview:navigationController.view];
    
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
