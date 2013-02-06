//
//  MySuperApplicationTests.m
//  MySuperApplicationTests
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

#import "MySuperApplicationTests.h"

#define VD_CLIENT_ID @"CLIENT_ID"
#define VD_CLIENT_SECRET @"CLIENT_SECRET"

@implementation MySuperApplicationTests

#pragma mark -
#pragma mark Unit Test Methods
- (void)testAllocations
{
    Viadeo *_viadeoConnect = [[Viadeo alloc] initWithClientID:VD_CLIENT_ID ClientSecret:VD_CLIENT_SECRET Delegate:self];
    if (!_viadeoConnect) {
        STFail(@"Viadeo Init Error");
    }
    [_viadeoConnect release];
    
    VDLoginPopUp *_loginPopUp = [[VDLoginPopUp alloc] initWithURL:@"" ClientID:VD_CLIENT_ID ClientSecret:VD_CLIENT_SECRET Delegate:self];
    if (!_loginPopUp) {
        STFail(@"VDLoginPopUp Init Error");
    }
    [_loginPopUp release];
    
    VDPopUp *_popUp = [[VDPopUp alloc] init];
    if (!_popUp) {
        STFail(@"VDPopUp Init Error");
    }
    [_popUp release];
    
    VDRequest *_requestManager = [[VDRequest alloc] init];
    if (!_requestManager) {
        STFail(@"VDRequest Init Error");
    }
    [_requestManager release];
}

- (void)setUp
{
    [super setUp];
    [self testAllocations];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in MySuperApplicationTests");
    
    [self setUp];
}

#pragma mark -
#pragma mark Deallocation
- (void)dealloc {
    [super dealloc];
}

@end
