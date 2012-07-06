//
//  ChangeUserName.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/20/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ChangeUserName.h"
#import "Authentication.h"

@interface ChangeUserName ()

@property (nonatomic, copy) NSString *changedUsername;

@end

@implementation ChangeUserName

@synthesize delegate = _delegate;
@synthesize changedUsername = _changedUsername;

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
    self.changedUsername = newUsername;
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:currentUsername, newUsername, self.auth.authToken, nil] forKeys:[NSArray arrayWithObjects:@"username", @"newUsername", SERVER_AUTH_TOKEN_KEY, nil]];
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"changeUserName"]];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    assert(self.changedUsername);
    self.auth.username = self.changedUsername;
    [self broadcastServerOperationSucceeded];
}

@end
