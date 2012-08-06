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

@property (nonatomic, retain) Login *login;

@end

@implementation LoginScreen
@synthesize nameField, pwField;
@synthesize login = _login;

-(id)init
{
    if (self = [super init]) {
        nameField = [self addTextFieldWithFrame:CGRectMake(self.contentSize.height*4/5, self.contentSize.width/2, 150, 30)];
        nameField.placeholder = @"Username";
        nameField.delegate    = self;
        
        pwField = [self addTextFieldWithFrame:CGRectMake(self.contentSize.height*3/5, self.contentSize.width/2, 150, 30)];
        pwField.clearsOnBeginEditing = YES;
        pwField.placeholder          = @"Password";
        pwField.secureTextEntry      = YES;
        pwField.delegate             = self;
    }
    return self;
}

- (Login *)login
{
    if(!_login) {
        _login = [[Login alloc]init];
        _login.delegate = self;
    }
    return _login;
}

- (void)pressedLogin:(id)sender
{
    NSString *username = nameField.text;
    NSString *password = pwField.text;
    [self startActivityIndicator];
    [self.login loginWithUsername:username password:password];
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

- (NSArray *)textFields
{
    return [NSArray arrayWithObjects:nameField, pwField, nil];
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
