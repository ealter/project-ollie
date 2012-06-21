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
#import "NSDictionary+URLEncoding.h"

@interface FacebookLogin () <FBSessionDelegate, FBRequestDelegate>

- (void)loginWithFacebookID:(NSString *)userId;

@end

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

- (void)loginWithFacebookID:(NSString *)userId
{
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc]initWithCapacity:3];
    [requestData setObject:userId forKey:@"facebookUserId"];
    if(self.auth.authToken) {
        [requestData setObject:self.auth.authToken forKey:SERVER_AUTH_TOKEN_KEY];
        [requestData setObject:self.auth.username forKey:@"username"];
    }
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"facebookLogin"]];
    [requestData release];
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
    [defaults setObject:[self.facebook accessToken]    forKey:FB_ACCESS_TOKEN_KEY];
    [defaults setObject:[self.facebook expirationDate] forKey:FB_EXPIRATION_DATE_KEY];
    [defaults synchronize];
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:FB_ACCESS_TOKEN_KEY];
    [defaults removeObjectForKey:FB_EXPIRATION_DATE_KEY];
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
    [defaults setObject:accessToken forKey:FB_ACCESS_TOKEN_KEY];
    [defaults setObject:expiresAt   forKey:FB_EXPIRATION_DATE_KEY];
    [defaults synchronize];
}

- (void)fbSessionInvalidated
{

}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    [self broadcastServerOperationFailedWithError:[error localizedDescription]];
}

//TODO: this method assumes that the request was for @"me"
- (void)request:(FBRequest *)request didLoad:(id)result
{
    if(!result) {
        [self broadcastServerOperationFailedWithError:nil];
        return;
    }
    NSDictionary *dict;
    if([request isKindOfClass:[NSArray class]])
        dict = [(NSArray *)result objectAtIndex:0];
    else {
        assert([result isKindOfClass:[NSDictionary class]]);
        dict = result;
    }
    NSString *userId = [dict objectForKey:@"id"];
    if(!userId) {
        DebugLog(@"The user id for the user is nil!");
        [self broadcastServerOperationFailedWithError:@"Facebook API returned junk"];
        return;
    }
    [self loginWithFacebookID:userId];
}

@end
