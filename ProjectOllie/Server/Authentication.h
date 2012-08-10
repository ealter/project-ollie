//
//  Authentication.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/15/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/* A singleton class that handles server authentication */

extern const NSString *kUsernameChangedBroadcast;

@class FacebookLogin;

@interface Authentication : NSObject

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) FacebookLogin *facebookLogin;
@property (nonatomic, readonly) BOOL isLoggedIn;

+ (Authentication *)mainAuth;

@end
