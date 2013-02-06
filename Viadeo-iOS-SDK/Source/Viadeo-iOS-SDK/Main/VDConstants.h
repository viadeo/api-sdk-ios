//
//  VDConstants.h
//  MySuperApplication
//
//  Created by Viadeo on 30/08/11.
//  Copyright 2011 Viadeo. All rights reserved.
//

// Log Functions
#ifdef DEBUG
    #define VDLogv(fmt, ...) NSLogv((fmt), ##__VA_ARGS__);
    #define VDLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
    #define VDLogWithLine(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define VDLogv(...)
    #define VDLog(...)
    #define VDLogWithLine(...)
#endif

// Requests

//#define VD_AUTHORIZATION_URL @"http://integws.smallbusiness.local/oauth-provider/authorize2"
#define VD_AUTHORIZATION_URL @"https://secure.viadeo.com/oauth-provider/authorize2"
#define VD_AUTHORIZATION_URL_PARAMETERS @"%@?response_type=code&display=popup&lang=%@&client_id=%@&redirect_uri=%@&cancel_url=%@"
#define VD_GET_ACCESS_TOKEN_URL @"https://secure.viadeo.com/oauth-provider/access_token2"

#define VD_API_DEV_URL @"%@://dev.viadeo.com/%@"
#define VD_API_PROD_URL @"%@://api.viadeo.com/%@"

#define VD_API_DEV 2
#define VD_API_PROD 3

//#define VD_API VD_API_DEV
#define VD_API VD_API_PROD

#if VD_API == VD_API_DEV
    #define VD_SERVER_TOKEN @"access_token"
    #define VD_API_URL VD_API_DEV_URL
#elif VD_API == VD_API_PROD
    #define VD_SERVER_TOKEN @"access_token"
    #define VD_API_URL VD_API_PROD_URL
#endif

#define VD_GET_ACCESS_TOKEN_PARAM @"%@?%@=%@"

// Notifications name
#define VD_VIADEO_API_REQUEST_NOTIFICATION_OK @"VD_VIADEO_API_REQUEST_NOTIFICATION_OK"
#define VD_VIADEO_API_REQUEST_NOTIFICATION_KO @"VD_VIADEO_API_REQUEST_NOTIFICATION_KO"

// PopUp URLs
#define VD_REDIRECT_URL @"http://www.viadeo-connect.com"
#define VD_CANCEL_REDIRECT_URL @"http://www.viadeo-connect.com/cancel"

// PopUp Constants
#define VD_POPUP_SHOW_DURATION 0.15
#define VD_POPUP_BOUNCING_DURATION 0.15
#define VD_POPUP_DISMISSING_DURATION 0.3
#define VD_POPUP_TITLE_MARGIN_X 3
#define VD_POPUP_TITLE_MARGIN_Y 4
#define VD_POPUP_PADDING 10
#define VD_POPUP_BORDER_WIDTH 10
#define VD_POPUP_BORDER_HEIGHT 10

// Time Out
#define VD_LOGIN_POPUP_AUTHORIZATION_TIME_OUT 60.0
#define VD_REQUEST_TIME_OUT 60.0

// HTTP Methods
#define VD_HTTP_METHOD_GET @"GET"
#define VD_HTTP_METHOD_POST @"POST"
#define VD_HTTP_METHOD_PUT @"PUT"
#define VD_HTTP_METHOD_DELETE @"DELETE"

// Error Constants
#define VIADEO_API_ERROR @"ViadeoAPIError"
