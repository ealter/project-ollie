//
//  LoginScreen.m
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginScreen.h"
#import "CCBReader.h"
#import "Authentication.h"

@interface LoginScreen ()

- (void)onSuccessfulLogin:(NSNotification *)notification;
- (void)onFailedLogin:(NSNotification *)notification;

@end

@implementation LoginScreen
@synthesize nameField, pwField;

-(id)init
{
    if(self = [super init])
    {
        CGRect nameframe = CGRectMake(self.contentSize.height*3/5, self.contentSize.width/2-15, 150, 30);
        nameField = [[UITextField alloc]initWithFrame:nameframe];
        nameField.clearsOnBeginEditing = YES;
        nameField.placeholder = @"Username";
        nameField.keyboardType = UIKeyboardTypeDefault;
        nameField.returnKeyType = UIReturnKeyDone;
        nameField.autocorrectionType = UITextAutocorrectionTypeNo;
        nameField.adjustsFontSizeToFitWidth = YES;
        nameField.textColor = [UIColor blackColor];
        [nameField setFont:[UIFont fontWithName:@"Arial" size:14]];
        nameField.backgroundColor = [UIColor clearColor];
        nameField.borderStyle = UITextBorderStyleRoundedRect;
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
        nameField.transform = transform;
        
        CGRect pwframe = CGRectMake(self.contentSize.height*2/5, self.contentSize.width/2-15, 150, 30);
        pwField = [[UITextField alloc]initWithFrame:pwframe];
        pwField.clearsOnBeginEditing = YES;
        pwField.placeholder = @"Password";
        pwField.keyboardType = UIKeyboardTypeDefault;
        pwField.returnKeyType = UIReturnKeyDone;
        pwField.autocorrectionType = UITextAutocorrectionTypeNo;
        pwField.adjustsFontSizeToFitWidth = YES;
        pwField.secureTextEntry = YES;
        pwField.textColor = [UIColor blackColor];
        [pwField setFont:[UIFont fontWithName:@"Arial" size:14]];
        pwField.backgroundColor = [UIColor clearColor];
        pwField.borderStyle = UITextBorderStyleRoundedRect;
        pwField.transform = transform;
        
        [nameField setDelegate:self];
        [pwField setDelegate:self];
        
        [[[[CCDirector sharedDirector] view] window] addSubview:nameField];
        [[[[CCDirector sharedDirector] view] window] addSubview:pwField];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)pressedLogin:(id)sender
{
    NSString *username = [nameField text];
    NSString *password = [pwField text];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSuccessfulLogin) name:LOGIN_SUCCEEDED_NOTIFIATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFailedLogin:) name:LOGIN_FAILED_NOTIFICATION object:nil];
    [[Authentication mainAuth] loginWithUsername:username password:password];
}

- (void)onSuccessfulLogin:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [nameField removeFromSuperview];
    [nameField release];
    [pwField removeFromSuperview];
    [pwField release];
    
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

- (void)onFailedLogin:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSString *error = notification.object;
    if(!error) error = @"unknown error";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error logging in" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    [self onSuccessfulLogin:nil]; //TODO: Make the person log in again
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
