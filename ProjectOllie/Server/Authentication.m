//
//  Authentication.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Authentication.h"

static Authentication *auth = nil;

#define BASE_URL [[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"]

@implementation Authentication

@synthesize authToken = _authToken;
@synthesize username = _username;

+ (Authentication *)mainAuth {
    if(!auth) {
        auth = [[Authentication alloc]init];
    }
    return auth;
}

- (BOOL)isLoggedIn
{
    return self.authToken != nil;
}

- (void)logout
{
    self.authToken = nil;
    //TODO: implement this on the server side
}

@end
