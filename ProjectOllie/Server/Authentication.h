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
@protocol Authentication_delegate <NSObject>
@optional
- (void)loginSucceeded;
- (void)loginFailedWithError:(NSString *)error;

@end

@interface Authentication : NSObject

@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, readonly, retain) NSString *username;
@property (nonatomic, readonly) BOOL isLoggedIn;
@property (nonatomic, assign) id<Authentication_delegate> delegate;

+ (Authentication *)mainAuth;

/* The NSString* functions return nil on success, an error message on failure */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)logout;

@end
