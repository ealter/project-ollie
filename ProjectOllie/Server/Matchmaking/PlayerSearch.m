//
//  PlayerSearch.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/3/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "PlayerSearch.h"

@implementation PlayerSearch

- (void)searchForPlayerWithUsername:(NSString *)username
{
    if(!username) {
        [self broadcastServerOperationFailedWithError:@"Missing username"];
        return;
    }
    NSDictionary *requestData = [NSDictionary dictionaryWithObject:username forKey:@"query"];
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"searchUsername"] includeAuthentication:NO];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    NSArray *usernames = [result objectForKey:@"usernames"];
    [self broadcastServerOperationSucceededWithData:usernames];
}

@end
