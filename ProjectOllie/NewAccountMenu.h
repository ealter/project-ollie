//
//  NewAccountMenu.h
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface NewAccountMenu : CCLayer <UITextFieldDelegate>

@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *pwField;
@property (nonatomic, retain) UITextField *cfpwField;

@end
