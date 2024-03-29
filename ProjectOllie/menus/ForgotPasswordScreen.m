//
//  ForgotPasswordScreen.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ForgotPasswordScreen.h"
#import "ResetPassword.h"

@interface ForgotPasswordScreen () <ServerAPI_delegate>
@end

@implementation ForgotPasswordScreen

- (id)init
{
    if(self = [super init]) {
        CGRect emailframe = CGRectMake(self.contentSize.width/2, self.contentSize.height*0.65, 150, 30);
        emailAddressField_ = [self addTextFieldWithFrame:emailframe];
        emailAddressField_.placeholder = @"Email";
    }
    return self;
}

- (void)pressedResetPassword:(id)sender
{
    ResetPassword *passwordResetter = [[ResetPassword alloc] init];
    passwordResetter.delegate = self;
    [passwordResetter resetPasswordForEmail:emailAddressField_.text];
}

- (void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"LoginScreen.ccbi"];
}

- (void)serverOperation:(ServerAPI *)operation succeededWithData:(id)data
{
    [self transitionToSceneWithFile:@"LoginScreen.ccbi"];
}

- (void)serverOperation:(ServerAPI *)operation failedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    [[[UIAlertView alloc]initWithTitle:@"Error resetting password" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

@end
