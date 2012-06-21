//
//  ChangeUserName.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/20/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAPI.h"

@protocol ChangeUserName_delegate <NSObject>

@optional
- (void)usernameChangeSucceded;
- (void)usernameChangeFailedWithError:(NSString *)error;

@end

@interface ChangeUserName : ServerAPI

@property (nonatomic, assign) id<ChangeUserName_delegate> delegate;

- (void)changeUserNameTo:(NSString *)newUsername;

@end
