//
//  MenuWithTextFields.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "MenuWithTextFields.h"

@implementation MenuWithTextFields

- (NSArray *)textFields
{
    return [NSArray array];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)transitionToSceneWithFile:(NSString *)sceneName
{
    [self removeUIViews:[self textFields]];
    [super transitionToSceneWithFile:sceneName];
}

@end
