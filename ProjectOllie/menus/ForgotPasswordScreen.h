//
//  ForgotPasswordScreen.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Menu.h"

@interface ForgotPasswordScreen : Menu <UITextFieldDelegate> {
    UITextField *emailAddressField_;
}

@end
