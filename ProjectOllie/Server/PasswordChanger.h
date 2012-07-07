//
//  PasswordChanger.h
//  ProjectOllie
//
//  Created by Eliot Alter on 7/5/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAccountsAPI.h"

@interface PasswordChanger : ServerAccountsAPI

- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword;

@end
