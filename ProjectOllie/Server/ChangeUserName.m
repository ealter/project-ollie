//
//  ChangeUserName.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/20/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ChangeUserName.h"
#import "Authentication.h"
#import "NSDictionary+URLEncoding.h"

@implementation ChangeUserName

@synthesize delegate = _delegate;

- (void)changeUserNameTo:(NSString *)newUsername
{
    NSString *currentUsername = self.auth.username;
    if(!currentUsername || !newUsername || currentUsername.length < 1 || newUsername.length < 1) {
        [self broadcastServerOperationFailedWithError:@"Missing username"];
        return;
    }
    NSURL *url = [[[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"] URLByAppendingPathComponent:@"changeUserName"];
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:currentUsername, newUsername, self.auth.authToken, nil] forKeys:[NSArray arrayWithObjects:@"username", @"newUsername", SERVER_AUTH_TOKEN_KEY, nil]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postData = [requestData urlEncodedString];
    [requestData release];
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLConnection alloc]initWithRequest:request delegate:self] release];
}

- (void)serverReturnedResult:(NSDictionary *)result {
    self.auth.authToken = [result objectForKey:SERVER_AUTH_TOKEN_KEY];
    if(self.auth.authToken)
        [self broadcastServerOperationSucceeded];
    else
        [self broadcastServerOperationFailedWithError:nil];
}

@end
