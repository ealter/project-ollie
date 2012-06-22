//
//  Logout.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/18/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Logout.h"
#import "Authentication.h"
#import "FacebookLogin.h"

@implementation Logout

- (void)logout
{
    Authentication *auth = [Authentication mainAuth];
    if(auth.username && auth.authToken) {
        NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:auth.username, auth.authToken, nil] forKeys:[NSArray arrayWithObjects:@"username", SERVER_AUTH_TOKEN_KEY, nil]];
        [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"logout"]];
        [requestData release];
    }
    auth.authToken = nil;
    [auth.facebookLogin logout];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    [self broadcastServerOperationSucceeded];
}

@end
