//
//  Authentication.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DOMAIN_NAME
#define DOMAIN_NAME @"http://106.187.44.7"
#endif

/* A singleton class that handles server authentication */

@interface Authentication : NSObject

@property (nonatomic, retain) NSString *authToken;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, readonly) BOOL isLoggedIn;

+ (Authentication *)mainAuth;

@end