//
//  IOS_Versions.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/27/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "IOS_Versions.h"

@implementation IOS_Versions

+ (BOOL)iOS_5 {
    NSString *osVersion = @"5.0";
    NSString *currOsVersion = [[UIDevice currentDevice] systemVersion];
    return [currOsVersion compare:osVersion options:NSNumericSearch] == NSOrderedDescending;
}

@end
