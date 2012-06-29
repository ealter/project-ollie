//
//  Authentication.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Authentication.h"
#import "FacebookLogin.h"

static Authentication *auth = nil;

#define USERNAME_KEY @"username"
#define AUTH_TOKEN_KEY @"auth_token"

@implementation Authentication

@synthesize authToken = _authToken;
@synthesize username = _username;
@synthesize facebookLogin = _facebookLogin;

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

- (FacebookLogin *)facebookLogin
{
    if(!_facebookLogin) {
        _facebookLogin = [[FacebookLogin alloc]init];
    }
    return _facebookLogin;
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:USERNAME_CHANGED_BROADCAST object:self]];
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAuthToken:(NSString *)authToken
{
    _authToken = authToken;
    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:AUTH_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
