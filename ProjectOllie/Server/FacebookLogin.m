//
//  FacebookLogin.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/19/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "FacebookLogin.h"
#import "Authentication.h"
#import "FBConnect.h"

@interface FacebookLogin () <FBSessionDelegate>

- (void)sendFacebookLoginDetailsToServer;

@end

@implementation FacebookLogin

@synthesize facebook = _facebook;

static NSString *kFBAccessTokenKey    = @"FBAccessTokenKey";
static NSString *kFBExpirationDateKey = @"FBExpirationDateKey";
static NSString *kAppId               = @"395624167150736";

- (Facebook *)facebook
{
    if(!_facebook) {
        _facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:kFBAccessTokenKey] 
            && [defaults objectForKey:kFBExpirationDateKey]) {
            _facebook.accessToken = [defaults objectForKey:kFBAccessTokenKey];
            _facebook.expirationDate = [defaults objectForKey:kFBExpirationDateKey];
        }
    }
    return _facebook;
}

- (void)login
{
    if (![self.facebook isSessionValid]) {
        [self.facebook authorize:nil];
    }
    else {
        [self sendFacebookLoginDetailsToServer];
    }
}

- (void)logout
{
    [self.facebook logout:self];
}

- (void)sendFacebookLoginDetailsToServer
{
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc]initWithCapacity:3];
    [requestData setObject:self.facebook.accessToken forKey:@"facebookAccessToken"];
    if(self.auth.authToken) {
        [requestData setObject:self.auth.authToken forKey:SERVER_AUTH_TOKEN_KEY];
        [requestData setObject:self.auth.username forKey:@"username"];
    }
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"facebookLogin"]];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    self.auth.authToken = [result objectForKey:SERVER_AUTH_TOKEN_KEY];
    self.auth.username  = [result objectForKey:@"username"];
    if(self.auth.authToken)
        [self broadcastServerOperationSucceeded];
    else
        [self broadcastServerOperationFailedWithError:nil];
}

- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken]    forKey:kFBAccessTokenKey];
    [defaults setObject:[self.facebook expirationDate] forKey:kFBExpirationDateKey];
    [defaults synchronize];
    [self sendFacebookLoginDetailsToServer];
}

- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kFBAccessTokenKey];
    [defaults removeObjectForKey:kFBExpirationDateKey];
    [defaults synchronize];
    //TODO: tell authentication class
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    if(cancelled) {
        [self broadcastServerOperationFailedWithError:@"Facebook login was cancelled"];
    }
    else {
        [self broadcastServerOperationFailedWithError:@"Facebook login failed for an unknown reason"];
    }
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:kFBAccessTokenKey];
    [defaults setObject:expiresAt   forKey:kFBExpirationDateKey];
    [defaults synchronize];
}

- (void)fbSessionInvalidated
{ }

@end
