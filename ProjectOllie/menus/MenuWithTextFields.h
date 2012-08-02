//
//  MenuWithTextFields.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Menu.h"

@interface MenuWithTextFields : Menu <UITextFieldDelegate>

//Subclasses should override this
- (NSArray *)textFields;

@end
