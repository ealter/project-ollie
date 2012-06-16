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

@end
