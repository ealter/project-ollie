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
    [self makeServerRequestWithData:nil url:[[self class] urlForPageName:@"numberOfTokens"] includeAuthentication:YES];
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
