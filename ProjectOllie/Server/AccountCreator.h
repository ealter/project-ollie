//
//  AccountCreator.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerAPI.h"

@protocol AccountCreator_Delegate <NSObject>
@optional
- (void)accountCreationSucceeded;
- (void)accountCreationFailedWithError:(NSString *)error;

@end

@interface AccountCreator : ServerAPI

@property (nonatomic, assign) id<AccountCreator_Delegate> delegate;

/* Creates an account. On success, it also logs the person in. */
- (void)createAccountWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email;

@end
