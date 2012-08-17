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
    //NSMutableDictionary *requestData = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:self.auth.username, self.auth.authToken, newPassword, nil] forKeys:[NSArray arrayWithObjects:@"username", SERVER_AUTH_TOKEN_KEY, @"newPassword", nil]];
    NSMutableDictionary *requestData = [NSMutableDictionary dictionaryWithObject:newPassword forKey:@"newPassword"];
    if(oldPassword)
        [requestData setObject:oldPassword forKey:@"oldPassword"];
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"changePassword"] includeAuthentication:YES];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    self.auth.authToken = [result objectForKey:SERVER_AUTH_TOKEN_KEY];
    if(self.auth.authToken)
        [self broadcastServerOperationSucceededWithData:nil];
    else
        [self broadcastServerOperationFailedWithError:@"Server did not send authorization token"];
}

@end
