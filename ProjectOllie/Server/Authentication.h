//
//  Authentication.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/* A singleton class that handles server authentication */

#define USERNAME_CHANGED_BROADCAST @"username changed"

@class FacebookLogin;

@interface Authentication : NSObject

@property (nonatomic, retain) NSString *authToken;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) FacebookLogin *facebookLogin;
@property (nonatomic, readonly) BOOL isLoggedIn;

+ (Authentication *)mainAuth;

@end
