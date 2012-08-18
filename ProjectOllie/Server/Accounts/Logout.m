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
    Authentication *auth = self.auth;
    if(auth.username && auth.authToken) {
        [self makeServerRequestWithData:nil url:[[self class] urlForPageName:@"logout"] includeAuthentication:YES];
    }
    auth.authToken = nil;
    [auth.facebookLogin logout];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    [self broadcastServerOperationSucceededWithData:nil];
}

@end
