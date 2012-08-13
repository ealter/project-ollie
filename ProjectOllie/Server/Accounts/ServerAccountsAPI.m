//
//  ServerAccountsAPI.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/20/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAccountsAPI.h"

@implementation ServerAccountsAPI

+ (NSURL *)urlForPageName:(NSString *)page
{
    return [[super urlForPageName:@"accounts"] URLByAppendingPathComponent:page];
}

@end
