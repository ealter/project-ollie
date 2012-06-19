//
//  FacebookLogin.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/19/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "FacebookLogin.h"

@implementation FacebookLogin

@synthesize facebook = _facebook;

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

- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:FB_ACCESS_TOKEN_KEY];
    [defaults setObject:[self.facebook expirationDate] forKey:FB_EXPIRATION_DATE_KEY];
    [defaults synchronize];
}

- (void)fbDidLogout
{

}

- (void)fbDidNotLogin:(BOOL)cancelled
{

}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{

}

- (void)fbSessionInvalidated
{

}

@end
