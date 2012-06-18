//
//  NSString+URLEncoding.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end