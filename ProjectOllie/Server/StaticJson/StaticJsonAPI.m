//
//  StaticJsonAPI.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/13/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "StaticJsonAPI.h"

@implementation StaticJsonAPI

+ (NSURL *)urlForPageName:(NSString *)page
{
    return [[[super urlForPageName:@"static"] URLByAppendingPathComponent:@"json"] URLByAppendingPathComponent:page];
}

@end
