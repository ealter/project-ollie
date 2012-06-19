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

@property (nonatomic, strong) NSURLConnection *connection;

- (void)broadcastLoginSucceeded;
- (void)broadcastLoginFailedWithError:(NSString *)error;

@end

@implementation Login

@synthesize delegate = _delegate;
@synthesize connection = _connection;

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
    if(!username || !password || [username length] < 1 || [password length] < 1) {
        [self broadcastLoginFailedWithError:@"Missing username or password"];
        return;
    }
    self.auth.authToken = nil;
    self.auth.username = username;
    NSURL *loginURL = [[[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"] URLByAppendingPathComponent:@"login"];
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:username, password, nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", nil]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    request.HTTPMethod = @"POST";
    NSString *postData = [requestData urlEncodedString];
    [requestData release];
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    
    self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
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
    if([result objectForKey:SERVER_ERROR_KEY]) {
        NSString *error = [result objectForKey:SERVER_ERROR_KEY];
        DebugLog(@"Error when logging in with username %@: %@", self.auth.username, error);
        [self broadcastLoginFailedWithError:error];
        return;
    }
    self.auth.authToken = [result objectForKey:SERVER_AUTH_TOKEN_KEY];
    if(self.auth.authToken)
        [self broadcastLoginSucceeded];
    else
        [self broadcastLoginFailedWithError:nil];
}

@end
