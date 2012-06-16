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

#define BASE_URL [[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"]

@interface Login () <NSURLConnectionDelegate>

@property (retain) NSMutableData *data;
@property (nonatomic, strong) Authentication *auth;

- (void)broadcastLoginSucceeded;
- (void)broadcastLoginFailedWithError:(NSString *)error;

@end

@implementation Login

@synthesize delegate = _delegate;
@synthesize data = _data;
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

- (Authentication *)auth
{
    if(!_auth)
        _auth = [Authentication mainAuth];
    return _auth;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    self.auth.authToken = nil;
    self.auth.username = username;
    NSURL *loginURL = [BASE_URL URLByAppendingPathComponent:@"login"];
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:username, password, nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", nil]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[requestData urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
    
    self.data = [[NSMutableData alloc]initWithCapacity:128];
    [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [self.data appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                 message:[error localizedDescription]
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                       otherButtonTitles:nil] autorelease] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(!self.data) {
        [self broadcastLoginFailedWithError:nil];
        return;
    }
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&error];
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
