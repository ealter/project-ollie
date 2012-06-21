//
//  AccountCreator.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerAPI.h"

@interface AccountCreator : ServerAPI

/* Creates an account. On success, it also logs the person in. */
- (void)createAccountWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email;

@end
