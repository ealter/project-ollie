//
//  Authentication.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Authentication.h"

static Authentication *auth = nil;

#define USERNAME_KEY @"username"
#define AUTH_TOKEN_KEY @"auth_token"

@implementation Authentication

@synthesize authToken = _authToken;
@synthesize username = _username;

+ (Authentication *)mainAuth {
    if(!auth) {
        auth = [[Authentication alloc] init];
    }
    return auth;
}

- (id)init
{
    if(self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.username  = [defaults objectForKey:USERNAME_KEY];
        self.authToken = [defaults objectForKey:AUTH_TOKEN_KEY];
    }
    return self;
}

- (BOOL)isLoggedIn
{
    return self.authToken != nil;
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME_KEY];
}

- (void)setAuthToken:(NSString *)authToken
{
    _authToken = authToken;
    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:AUTH_TOKEN_KEY];
}

@end
