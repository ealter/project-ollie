//
//  NewAccountMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewAccountMenu.h"
#import "AccountCreator.h"
#import "cocos2d.h"

@interface NewAccountMenu () <ServerAPI_delegate>

@property (nonatomic, retain) AccountCreator *accountCreator;

@end

@implementation NewAccountMenu
@synthesize emailField, pwField, nameField, cfpwField;
@synthesize accountCreator = _accountCreator;

-(id)init
{
    if(self=[super init]) {
        CGRect nameframe = CGRectMake(self.contentSize.height*0.8, self.contentSize.width/2, 150, 30);
        nameField = [self addTextFieldWithFrame:nameframe];
        nameField.placeholder = @"Username";
        nameField.delegate    = self;
        
        CGRect pwframe = CGRectMake(self.contentSize.height*0.5, self.contentSize.width/2, 150, 30);
        pwField = [self addTextFieldWithFrame:pwframe];
        pwField.clearsOnBeginEditing = YES;
        pwField.placeholder          = @"Password";
        pwField.secureTextEntry      = YES;
        pwField.delegate             = self;
        
        CGRect cfpwframe = CGRectMake(self.contentSize.height*0.35, self.contentSize.width/2, 150, 30);
        cfpwField = [self addTextFieldWithFrame:cfpwframe];
        cfpwField.clearsOnBeginEditing = YES;
        cfpwField.placeholder          = @"Confirm Password";
        cfpwField.secureTextEntry      = YES;
        cfpwField.delegate             = self;
        
        CGRect emailframe = CGRectMake(self.contentSize.height*0.65, self.contentSize.width/2, 150, 30);
        emailField = [self addTextFieldWithFrame:emailframe];
        emailField.placeholder = @"Email";
        emailField.delegate    = self;
    }
    
    return self;
}

- (AccountCreator *)accountCreator
{
    if(!_accountCreator) {
        _accountCreator = [[AccountCreator alloc]init];
        _accountCreator.delegate = self;
    }
    return _accountCreator;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

//TODO: make user repeat password?
-(void)pressedMake:(id)sender
{
    NSString *username = nameField.text;
    NSString *password = pwField.text;
    NSString *email    = emailField.text;
    [self startActivityIndicator];
    [self.accountCreator createAccountWithUsername:username password:password email:email];
}

- (void)transitionToSceneWithFile:(NSString *)sceneName
{
    [self removeUIViews:[NSArray arrayWithObjects:nameField, cfpwField, pwField, emailField, nil]];
    [self transitionToSceneWithFile:sceneName];
}

-(void)pressedCancel:(id)sender
{
    [self transitionToSceneWithFile:@"LoginScreen.ccbi"];
}

- (void)serverOperationSucceeded
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    [[[UIAlertView alloc]initWithTitle:@"Error creating account" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

@end
