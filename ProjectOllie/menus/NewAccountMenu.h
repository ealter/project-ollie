//
//  NewAccountMenu.h
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"

@interface NewAccountMenu : Menu <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *pwField;
@property (nonatomic, strong) UITextField *cfpwField;

@end
