//
//  HighestVersion.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/13/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "HighestVersion.h"

@implementation HighestVersion

- (void)getHighestVersion
{
    [self makeServerRequestWithData:nil url:[[self class] urlForPageName:@"version.json"] includeAuthentication:NO];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    [self broadcastServerOperationFailedWithError:[result objectForKey:@"version"]];
}

@end
