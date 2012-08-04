//
//  ResetPassword.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAccountsAPI.h"

@interface ResetPassword : ServerAccountsAPI

- (void)resetPasswordForEmail:(NSString *)email;

@end
