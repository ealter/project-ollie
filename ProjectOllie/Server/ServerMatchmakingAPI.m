//
//  ServerMatchmakingAPI.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerMatchmakingAPI.h"

@implementation ServerMatchmakingAPI

+ (NSURL *)urlForPageName:(NSString *)page
{
    return [[[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"matchmaking"] URLByAppendingPathComponent:page];
}

@end
