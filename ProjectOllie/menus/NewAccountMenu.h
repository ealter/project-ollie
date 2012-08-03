//
//  NewAccountMenu.h
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "MenuWithTextFields.h"

@interface NewAccountMenu : MenuWithTextFields

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *pwField;
@property (nonatomic, strong) UITextField *cfpwField;

@end
