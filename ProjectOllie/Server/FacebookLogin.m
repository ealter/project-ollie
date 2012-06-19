//
//  FacebookLogin.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/19/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "FacebookLogin.h"

@interface FacebookLogin ()

- (void)broadcastLoginSucceeded;
- (void)broadcastLoginFailedWithError:(NSString *)error;

@end

@implementation FacebookLogin

@synthesize facebook = _facebook;
@synthesize delegate = _delegate;

#define FB_ACCESS_TOKEN_KEY @"FBAccessTokenKey"
#define FB_EXPIRATION_DATE_KEY @"FBExpirationDateKey"

- (Facebook *)facebook
{
    if(!_facebook) {
        _facebook = [[Facebook alloc] initWithAppId:@"395624167150736" andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:FB_ACCESS_TOKEN_KEY] 
            && [defaults objectForKey:FB_EXPIRATION_DATE_KEY]) {
            _facebook.accessToken = [defaults objectForKey:FB_ACCESS_TOKEN_KEY];
            _facebook.expirationDate = [defaults objectForKey:FB_EXPIRATION_DATE_KEY];
        }
    }
    return _facebook;
}

- (void)login
{
    if (![self.facebook isSessionValid]) {
        [self.facebook authorize:nil];
    }
}

- (void)logout
{
    [self.facebook logout:self];
}

- (void)broadcastLoginSucceeded
{
    if([self.delegate respondsToSelector:@selector(loginSucceeded)])
        [self.delegate loginSucceeded];
}

- (void)broadcastLoginFailedWithError:(NSString *)error
{
    if([self.delegate respondsToSelector:@selector(loginFailedWithError:)])
        [self.delegate loginFailedWithError:error];
}

- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken]    forKey:FB_ACCESS_TOKEN_KEY];
    [defaults setObject:[self.facebook expirationDate] forKey:FB_EXPIRATION_DATE_KEY];
    [defaults synchronize];
}

- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:FB_ACCESS_TOKEN_KEY];
    [defaults removeObjectForKey:FB_EXPIRATION_DATE_KEY];
    [defaults synchronize];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    if(cancelled) {
        [self broadcastLoginFailedWithError:@"Facebook login was cancelled"];
    }
    else {
        [self broadcastLoginFailedWithError:@"Facebook login failed for an unknown reason"];
    }
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:FB_ACCESS_TOKEN_KEY];
    [defaults setObject:expiresAt   forKey:FB_EXPIRATION_DATE_KEY];
    [defaults synchronize];
}

- (void)fbSessionInvalidated
{

}

@end
