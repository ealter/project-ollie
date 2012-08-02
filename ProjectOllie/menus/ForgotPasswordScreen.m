//
//  ForgotPasswordScreen.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ForgotPasswordScreen.h"

@implementation ForgotPasswordScreen

- (id)init
{
    if(self = [super init]) {
        CGRect emailframe = CGRectMake(self.contentSize.height*0.65, self.contentSize.width/2, 150, 30);
        emailAddressField_ = [self addTextFieldWithFrame:emailframe];
        emailAddressField_.placeholder = @"Email";
        emailAddressField_.delegate    = self;
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)pressedResetPassword:(id)sender
{
    //TODO
}

- (void)serverOperationSucceeded
{
    [self transitionToSceneWithFile:@"LoginScreen.ccbi"];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    [[[UIAlertView alloc]initWithTitle:@"Error resetting password" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

@end
