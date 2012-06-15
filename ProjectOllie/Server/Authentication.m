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

@interface Authentication ()

+ (NSString *)errorForServerResult:(NSDictionary *)result;

@end

@implementation Authentication

@synthesize authToken = _authToken;
@synthesize username = _username;

+ (Authentication *)mainAuth {
    if(!auth) {
        auth = [[Authentication alloc]init];
    }
    return auth;
}

+ (NSString *)errorForServerResult:(NSDictionary *)result
{
    return [result objectForKey:@"error"];
}

- (BOOL)isLoggedIn
{
    return self.authToken != nil;
}

- (NSString *)loginWithUsername:(NSString *)username password:(NSString *)password
{
    self.authToken = nil;
    _username = username;
    NSURL *loginURL = [BASE_URL URLByAppendingPathComponent:@"login"];
    NSData *data = [NSData dataWithContentsOfURL:loginURL];
    assert(data); //TODO: return an error instead
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error when logging in with username %@: %@", username, error);
        return @"Internal server error";
    }
    if([[self class] errorForServerResult:result]) {
        NSString *error = [[self class] errorForServerResult:result];
        DebugLog(@"Error when logging in with username %@: %@", username, error);
        return error;
    }
    self.authToken = [result objectForKey:@"auth_token"];
    if(self.authToken)
        return nil;
    return @"Unknown error";
}

- (NSString *)logout
{
    self.authToken = nil;
    //TODO: implement this on the server side
    return nil;
}

@end
