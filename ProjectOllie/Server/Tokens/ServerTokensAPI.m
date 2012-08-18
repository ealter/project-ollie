//
//  ServerTokensAPI.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/17/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerTokensAPI.h"

@implementation ServerTokensAPI

+ (NSURL *)urlForPageName:(NSString *)page
{
    return [[super urlForPageName:@"tokens"] URLByAppendingPathComponent:page];
}

@end
