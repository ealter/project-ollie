//
//  PasswordChangeScreen.h
//  ProjectOllie
//
//  Created by Eliot Alter on 7/5/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Menu.h"

@interface PasswordChangeScreen : Menu <UITextFieldDelegate> {
    UITextField *oldPasswordField_;
    UITextField *newPasswordField_;
    UITextField *confirmPasswordField_;
}

@end
