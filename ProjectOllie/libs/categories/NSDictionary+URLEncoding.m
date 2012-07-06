//
//  NSDictionary+URLEncoding.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "NSDictionary+URLEncoding.h"
#import "NSString+URLEncoding.h"

@implementation NSDictionary (UrlEncoding)

- (NSString*)urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (NSString *key in self) {
        NSString *value = [self objectForKey: key];
        if(!([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])) continue;
        NSString *part = [NSString stringWithFormat:@"%@=%@", [key urlEncodeUsingEncoding:NSUTF8StringEncoding], [value urlEncodeUsingEncoding:NSUTF8StringEncoding]];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}

@end
