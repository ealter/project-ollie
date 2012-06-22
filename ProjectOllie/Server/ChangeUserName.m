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
    if(!self.auth.authToken) {
        [self broadcastServerOperationFailedWithError:@"Missing authentication"];
        return;
    }
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:currentUsername, newUsername, self.auth.authToken, nil] forKeys:[NSArray arrayWithObjects:@"username", @"newUsername", SERVER_AUTH_TOKEN_KEY, nil]];
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"changeUserName"]];
    [requestData release];
}

- (void)serverReturnedResult:(NSDictionary *)result {
    [self broadcastServerOperationSucceeded];
}

@end
