//
//  LoginScreen.m
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
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
        nameField = [self addTextFieldWithFrame:CGRectMake(self.contentSize.height*3/5, self.contentSize.width/2-15, 150, 30)];
        nameField.placeholder = @"Username";
        nameField.delegate    = self;
        
        pwField = [self addTextFieldWithFrame:CGRectMake(self.contentSize.height*2/5, self.contentSize.width/2-15, 150, 30)];
        pwField.clearsOnBeginEditing = YES;
        pwField.placeholder          = @"Password";
        pwField.secureTextEntry      = YES;
        pwField.delegate             = self;
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
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
    [self.login loginWithUsername:username password:password];
}

- (void)pressedLoginWithFacebook:(id)sender
{
    FacebookLogin *login = [Authentication mainAuth].facebookLogin;
    login.delegate = self;
    [login login];
    //TODO: maybe release login?
}

//Called when login succeeds
- (void)serverOperationSucceeded
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi" removeUIViews:[NSArray arrayWithObjects:nameField, pwField, nil]];
}

//Called when login fails
- (void)serverOperationFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error logging in" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self serverOperationSucceeded]; //TODO: Make the person log in again
}

-(void)pressedMakeNew:(id)sender
{
    [self transitionToSceneWithFile:@"NewAccountMenu.ccbi" removeUIViews:[NSArray arrayWithObjects:nameField, pwField, nil]];
}

@end
