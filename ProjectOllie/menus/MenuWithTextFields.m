//
//  MenuWithTextFields.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "MenuWithTextFields.h"
#import "CCDirector.h"
#import "CCUIViewWrapper.h"

@implementation MenuWithTextFields

- (id)init
{
    if(self = [super init]) {
        textFields_ = [NSMutableArray array];
    }
    return self;
}

- (UITextField *)addTextFieldWithFrame:(CGRect)frame
{
    UITextField *field = [[UITextField alloc]initWithFrame:frame];
    field.clearsOnBeginEditing = NO;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.adjustsFontSizeToFitWidth = YES;
    [field setFont:[UIFont fontWithName:@"Arial" size:14]];
    field.backgroundColor = [UIColor whiteColor];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.delegate = self;
    field.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    CCUIViewWrapper *wrapper = [CCUIViewWrapper wrapperForUIView:field];
    wrapper.position = ccp(frame.origin.x - frame.size.width/2, frame.origin.y + frame.size.height/2);
    wrapper.anchorPoint = ccp(0.5, 0.5);
    
    [self addChild:wrapper];
    [textFields_ addObject:field];
    return field;
}

- (void)removeUIViews:(NSArray *)uiviews
{
    for(UIView *view in uiviews) {
        if([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)transitionToSceneWithFile:(NSString *)sceneName
{
    [self removeUIViews:textFields_];
    [super transitionToSceneWithFile:sceneName];
}

@end
