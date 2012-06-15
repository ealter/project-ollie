//
//  Authentication.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Authentication.h"

static Authentication *auth = nil;

@implementation Authentication

+ (Authentication *)mainAuth {
    if(!auth) {
        auth = [[Authentication alloc]init];
    }
    return auth;
}

@end
