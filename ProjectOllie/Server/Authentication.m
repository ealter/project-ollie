//
//  Authentication.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Authentication.h"
#import "NSDictionary+URLEncoding.h"

static Authentication *auth = nil;

#define BASE_URL [[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"]

@interface Authentication () <NSURLConnectionDelegate>

@property (retain) NSMutableData *data;

+ (NSString *)errorForServerResult:(NSDictionary *)result;

@end

@implementation Authentication

@synthesize authToken = _authToken;
@synthesize username = _username;
@synthesize data = _data;
@synthesize delegate = _delegate;

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

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    self.authToken = nil;
    _username = username;
    NSURL *loginURL = [BASE_URL URLByAppendingPathComponent:@"login"];
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:username, password, nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", nil]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    request.HTTPMethod = @"get";
    request.HTTPBody = [[requestData urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
    
    self.data = [[NSMutableData alloc]initWithCapacity:128];
    [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (void)logout
{
    self.authToken = nil;
    //TODO: implement this on the server side
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
        [self.delegate loginFailedWithError:nil];
        return;
    }
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error when logging in with username %@: %@", self.username, error);
        [self.delegate loginFailedWithError:@"Internal server error"];
        return;
    }
    if([[self class] errorForServerResult:result]) {
        NSString *error = [[self class] errorForServerResult:result];
        DebugLog(@"Error when logging in with username %@: %@", self.username, error);
        [self.delegate loginFailedWithError:error];
        return;
    }
    self.authToken = [result objectForKey:@"auth_token"];
    if(self.authToken)
        [self.delegate loginSucceeded];
    else
        [self.delegate loginFailedWithError:nil];
}

@end
