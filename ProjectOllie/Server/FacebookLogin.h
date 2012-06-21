//
//  FacebookLogin.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/19/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAccountsAPI.h"
#import "Login.h"

@class Facebook;

@interface FacebookLogin : ServerAccountsAPI

@property (nonatomic, retain) Facebook *facebook;

- (void)login;
- (void)logout;

@end
