//
//  OptionsMenu.h
//  ProjectOllie
//
//  Created by Lion User on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"

@class CCLabelTTF;

@interface OptionsMenu : Menu <UITextFieldDelegate>{
    CCLabelTTF *userName;
    UITextField *nameField;
}

@end
