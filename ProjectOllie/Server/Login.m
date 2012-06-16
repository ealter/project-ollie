//
//  Login.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Login.h"
#import "Authentication.h"
#import "NSDictionary+URLEncoding.h"

@interface Login ()

- (void)broadcastLoginSucceeded;
- (void)broadcastLoginFailedWithError:(NSString *)error;

@end

@implementation Login

@synthesize delegate = _delegate;
@synthesize auth = _auth;

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

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    self.auth.authToken = nil;
    self.auth.username = username;
    NSURL *loginURL = [[[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"] URLByAppendingPathComponent:@"login"];
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:username, password, nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", nil]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[requestData urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
    
    data_ = [[NSMutableData alloc]initWithCapacity:128];
    [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(!data_) {
        [self broadcastLoginFailedWithError:nil];
        return;
    }
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data_ options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error when logging in with username %@: %@", self.auth.username, error);
        [self broadcastLoginFailedWithError:@"Internal server error"];
        return;
    }
    if([result objectForKey:@"error"]) {
        NSString *error = [result objectForKey:@"error"];
        DebugLog(@"Error when logging in with username %@: %@", self.auth.username, error);
        [self broadcastLoginFailedWithError:error];
        return;
    }
    self.auth.authToken = [result objectForKey:@"auth_token"];
    if(self.auth.authToken)
        [self broadcastLoginSucceeded];
    else
        [self broadcastLoginFailedWithError:nil];
}

@end
