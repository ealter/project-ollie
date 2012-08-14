//
//  LoginScreen.m
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "LoginScreen.h"
#import "cocos2d.h"
#import "Login.h"
#import "FacebookLogin.h"
#import "Authentication.h"

@interface LoginScreen () <ServerAPI_delegate>
@end

@implementation LoginScreen
@synthesize nameField, pwField;

-(id)init
{
    if (self = [super init]) {
        nameField = [self addTextFieldWithFrame:CGRectMake(self.contentSize.width/2, self.contentSize.height*4/5, 150, 30)];
        nameField.placeholder = @"Username";
        
        pwField = [self addTextFieldWithFrame:CGRectMake(self.contentSize.width/2, self.contentSize.height*3/5, 150, 30)];
        pwField.clearsOnBeginEditing = YES;
        pwField.placeholder          = @"Password";
        pwField.secureTextEntry      = YES;
    }
    return self;
}

- (void)pressedLogin:(id)sender
{
    NSString *username = nameField.text;
    NSString *password = pwField.text;
    [self startActivityIndicator];
    Login *login = [[Login alloc] init];
    login.delegate = self;
    [login loginWithUsername:username password:password];
}

- (void)pressedLoginWithFacebook:(id)sender
{
    FacebookLogin *login = [Authentication mainAuth].facebookLogin;
    login.delegate = self;
    [login login];
}

- (void)pressedForgotPassword:(id)sender
{
    [self transitionToSceneWithFile:@"ForgotPassword.ccbi"];
    DebugLog(@"I forgot my password!");
}

//Called when login succeeds
- (void)serverOperationSucceededWithData:(id)data
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

//Called when login fails
- (void)serverOperationFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    [[[UIAlertView alloc]initWithTitle:@"Error logging in" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    [self serverOperationSucceededWithData:nil]; //TODO: Make the person log in again
}

-(void)pressedMakeNew:(id)sender
{
    [self transitionToSceneWithFile:@"NewAccountMenu.ccbi"];
}

@end
