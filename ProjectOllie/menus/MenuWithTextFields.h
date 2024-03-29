//
//  MenuWithTextFields.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Menu.h"

@interface MenuWithTextFields : Menu <UITextFieldDelegate> {
    NSMutableArray *textFields_;
}

//If uiviews is not nil, it calls removeFromSuperview and release on each element.
- (void)removeUIViews:(NSArray *)uiviews;

//Adds a text field setting a bunch of common parameters
- (UITextField *)addTextFieldWithFrame:(CGRect)frame;

@end
