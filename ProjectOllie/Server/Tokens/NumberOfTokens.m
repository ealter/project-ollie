//
//  NumberOfTokens.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/17/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "NumberOfTokens.h"
#import "Authentication.h"

@implementation NumberOfTokens

- (void)getNumberofTokens
{
    if(!self.auth.username) {
        [self broadcastServerOperationFailedWithError:@"Unknown username"];
    } else if(!self.auth.authToken) {
        [self broadcastServerOperationFailedWithError:@"Missing authorization token. Please try logging in again"];
    } else {
        NSDictionary *requestData = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.auth.username, self.auth.authToken, nil] forKeys:[NSArray arrayWithObjects:@"username", SERVER_AUTH_TOKEN_KEY, nil]];
        [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"numberOfTokens"]];
    }
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    if(result) {
        [self broadcastServerOperationSucceededWithData:[result objectForKey:@"tokens"]];
    } else {
        [self broadcastServerOperationFailedWithError:nil];
    }
}

@end
