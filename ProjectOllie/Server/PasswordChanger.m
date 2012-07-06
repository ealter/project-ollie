//
//  PasswordChanger.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/5/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "PasswordChanger.h"
#import "Authentication.h"

@implementation PasswordChanger

- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword
{
    if(!newPassword) {
        [self broadcastServerOperationFailedWithError:@"Missing new password"];
        return;
    }
    if(!self.auth.username) {
        [self broadcastServerOperationFailedWithError:@"Unknown username"];
        return;
    }
    NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:self.auth.username, self.auth.authToken, oldPassword, newPassword, nil] forKeys:[NSArray arrayWithObjects:@"username", SERVER_AUTH_TOKEN_KEY, @"oldPassword", @"newPassword", nil]];
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"changePassword"]];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    self.auth.authToken = [result objectForKey:SERVER_AUTH_TOKEN_KEY];
    if(self.auth.authToken)
        [self broadcastServerOperationSucceeded];
    else
        [self broadcastServerOperationFailedWithError:nil];
}

@end
