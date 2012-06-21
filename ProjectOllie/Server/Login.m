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

@end

@implementation Login

@synthesize connection = _connection;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    if(!username || !password || [username length] < 1 || [password length] < 1) {
        [self broadcastServerOperationFailedWithError:@"Missing username or password"];
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
        [self broadcastServerOperationFailedWithError:nil];
        return;
    }
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data_ options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error when logging in with username %@: %@", self.auth.username, error);
        [self broadcastServerOperationFailedWithError:@"Internal server error"];
        return;
    }
    if([result objectForKey:SERVER_ERROR_KEY]) {
        NSString *error = [result objectForKey:SERVER_ERROR_KEY];
        DebugLog(@"Error when logging in with username %@: %@", self.auth.username, error);
        [self broadcastServerOperationFailedWithError:error];
        return;
    }
    self.auth.authToken = [result objectForKey:SERVER_AUTH_TOKEN_KEY];
    if(self.auth.authToken)
        [self broadcastServerOperationSucceeded];
    else
        [self broadcastServerOperationFailedWithError:nil];
}

@end
