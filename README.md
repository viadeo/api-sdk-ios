# Viadeo iOS SDK for iPhone/iPad

**This is BETA software, you can report bugs using the [support form](http://dev.viadeo.com/technical-support/).**

## Step 1: Installation

You will need to download and install XCode and the latest version of Viadeo iOS SDK:

* Download & Install XCode

* Download Viadeo-iOS-SDK
After including the SDK source files into the app project, an #import declaration must be added to a header file to ensure that the app can reference the SDK types in the app source files: #import "VDConnect.h"
With this step complete, the Viadeo iOS SDK can be built and used within the app XCode project.

Implementing Viadeo iOS SDK
General
 First modify the AppDelegate Class.

*  Set the AppDelegate class to handle the Viadeo delegate callbacks by adding ViadeoConnectDelegate and VDRequestDelegate to the list of delegates. For example for the MySuperApplication:
@interface MySuperApplicationAppDelegate : NSObject <UIApplicationDelegate, ViadeoConnectDelegate, VDRequestDelegate>

* Set up the AppDelegate header file by creating instance variable:

Viadeo *viadeo;

* Step 3. Add a property for an instance of the Viadeo class:

@property (nonatomic, retain) Viadeo *viadeo;

Then modify the AppDelegate implementation file.

* Synthesize and release the viadeo property:

Synthesize:

```java
	@synthesize viadeo;
```

Deallocate:

```java
- (void)dealloc {
	self.viadeo = nil;
	 [_window release]
	 ; [super dealloc]; }
```

* Fill VD_CLIENT_ID and VD_CLIENT_SECRET constants with your client ID and client secret given by your Viadeo Developer Account.


## Step 2: Log In

* Logging in Viadeo

```java
if (!viadeo) {
	viadeo = [[Viadeo alloc] initWithClientID:VD_CLIENT_ID ClientSecret:VD_CLIENT_SECRET Delegate:self];
 }

if (![viadeo isLoggedIn]) {
	[viadeo authorize];
 }
```

* Implementing the Viadeo Log In Delegate methods.

```java
- (void)viadeoDidLogin {
	// You are connected to Viadeo
}

- (void)viadeoDidNotLogin:(BOOL)_cancelled withError:(NSError *)_error {
  // An error occured while logging in
}
```


## Step 3: Log Out

```java
	[viadeo logOut];
```


## Step 4: Calling the Viadeo API

* The iOS SDK provides a straightforward set of methods to access the Viadeo API.

* GET

```java
// GET me
 [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me" andDelegate:self];

// GET me/tags
 [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me/tags" andDelegate:self];

// GET me in english language
 NSMutableDictionary *_query = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"en", @"language", nil]; [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me" andQuery:_query andDelegate:self];

// GET me/contacts
 _query = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:50], @"limit", nil]; [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me/contacts" andQuery:_query andDelegate:self];

// GET me/visits => only for Level 3 users
 _query = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3], @"limit", nil]; [viadeo requestWithHttpMethod:VD_HTTP_METHOD_GET andGraphPath:@"me/visits" andQuery:_query andDelegate:self];
```

* POST

```java
// POST status
 NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"hello from iOS Viadeo SDK", @"message", nil];  [viadeo requestWithHttpMethod:VD_HTTP_METHOD_POST andGraphPath:@"status" andParams:_params andDelegate:self];

// POST me/tags
 NSMutableDictionary *_tagParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"friends", @"tag", @"...", @"contact_id", nil]; [viadeo requestWithHttpMethod:VD_HTTP_METHOD_POST andGraphPath:@"me/tags" andParams:_tagParams andDelegate:self];

 // POST me/career  NSMutableDictionar *_careerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Nintendo", @"company", @"Level Designer", @"position", [NSNumber numberWithInt:2004], @"from", [NSNumber numberWithInt:2005], @"to", @"High Tech", @"company_industry", nil];  [viadeo requestWithHttpMethod:VD_HTTP_METHOD_POST andGraphPath:@"me/career" andParams:_careerParams andDelegate:self];
```

* PUT

```java
// PUT me
 NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Newton Corp Co-Founder, Freelancer, Viadeo iOS Lead Developer", @"headline", @"iPhone, iPad", @"introduction", @"Football, Cinema", @"interests", nil];  [viadeo requestWithHttpMethod:VD_HTTP_METHOD_PUT andGraphPath:@"me" andParams:_params andDelegate:self];
```

* DELETE

```java
// DELETE me/tags
 NSMutableDictionary *_tagParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"friends", @"tag", @"...", @"contact_id", nil]; [viadeo requestWithHttpMethod:VD_HTTP_METHOD_DELETE andGraphPath:@"me/tags" andParams:_tagParams andDelegate:self];
```


## Step 5: Implementing the Viadeo API Delegate methods.

These methods are called asynchronously; the viadeoRequest:didLoad: method for successful requests and viadeoRequest:didFailWithError: method for errors must be implemented.

```java
- (void)viadeoRequest:(VDRequest *)_request didLoad:(NSDictionary *)_dictionary {
 }
- (void)viadeoRequest:(VDRequest *)_request didFailWithError:(NSError *)_error {
 }
```