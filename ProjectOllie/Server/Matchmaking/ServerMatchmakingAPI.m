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
    return [[super urlForPageName:@"marketing"] URLByAppendingPathComponent:page];
}

@end
