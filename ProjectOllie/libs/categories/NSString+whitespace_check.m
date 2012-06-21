//
//  NSString+whitespace_check.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/17/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "NSString+whitespace_check.h"

@implementation NSString (whitespace_check)

- (BOOL)hasWhitespace
{
    NSRange range = [self rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return range.location != NSNotFound;
}

@end
