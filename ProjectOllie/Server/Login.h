//
//  Login.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerAccountsAPI.h"

@interface Login : ServerAccountsAPI

- (void)loginWithUsername:(NSString *)username password:(NSString *)password;

@end
