//
//  PasswordChangeScreen.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/5/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "PasswordChangeScreen.h"
#import "PasswordChanger.h"

@interface PasswordChangeScreen () <ServerAPI_delegate>
@end

@implementation PasswordChangeScreen

- (id)init
{
    if(self = [super init]) {
        const CGSize textfieldSize = CGSizeMake(150, 30);
        CGRect frame = CGRectMake(self.contentSize.height*4/5, self.contentSize.width/2, textfieldSize.width, textfieldSize.height);
        oldPasswordField_ = [self addTextFieldWithFrame:frame];
        oldPasswordField_.placeholder = @"Current Password";
        oldPasswordField_.secureTextEntry = YES;
        oldPasswordField_.delegate = self;
        
        frame = CGRectMake(self.contentSize.height*3/5, self.contentSize.width/2, textfieldSize.width, textfieldSize.height);
        newPasswordField_ = [self addTextFieldWithFrame:frame];
        newPasswordField_.placeholder = @"New Password";
        newPasswordField_.secureTextEntry = YES;
        newPasswordField_.delegate = self;
        
        frame = CGRectMake(self.contentSize.height*2/5, self.contentSize.width/2, textfieldSize.width, textfieldSize.height);
        confirmPasswordField_ = [self addTextFieldWithFrame:frame];
        confirmPasswordField_.placeholder = @"Confirm Password";
        confirmPasswordField_.secureTextEntry = YES;
        confirmPasswordField_.delegate = self;
    }
    return self;
}

- (void)serverOperationSucceeded
{
    [self pressedBack:self];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    [[[UIAlertView alloc]initWithTitle:@"Error when changing password" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

- (void)transitionToSceneWithFile:(NSString *)sceneName
{
    [self removeUIViews:[NSArray arrayWithObjects:oldPasswordField_, newPasswordField_, confirmPasswordField_, nil]];
    [super transitionToSceneWithFile:sceneName];
}

- (void)pressedChangePassword:(id)sender
{
    NSString *newPassword = newPasswordField_.text;
    if(![newPassword isEqualToString:confirmPasswordField_.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"The passwords do not match." delegate:nil cancelButtonTitle:@"okay" otherButtonTitles:nil] show];
         return;
    }
    PasswordChanger *passwordChanger = [[PasswordChanger alloc]init];
    passwordChanger.delegate = self;
    [passwordChanger changePasswordFrom:oldPasswordField_.text to:newPassword];
}

- (void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"OptionsMenu.ccbi"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

@end