//
//  FacebookLogin.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/19/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAPI.h"
#import "Login.h"

@class Facebook;

@interface FacebookLogin : ServerAPI

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, assign) id<Login_Delegate> delegate;

- (void)login;
- (void)logout;

@end
