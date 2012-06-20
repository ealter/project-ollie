//
//  LoginScreen.m
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginScreen.h"
#import "CCBReader.h"
#import "Login.h"
#import "FacebookLogin.h"
#import "Authentication.h"

@interface LoginScreen () <Login_Delegate>

@property (nonatomic, retain) Login *login;

@end

@implementation LoginScreen
@synthesize nameField, pwField;
@synthesize login = _login;

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
        nameField.backgroundColor = [UIColor whiteColor];
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
        pwField.backgroundColor = [UIColor whiteColor];
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
    NSString *username = [nameField text];
    NSString *password = [pwField text];
    [self.login loginWithUsername:username password:password];
}

- (void)pressedLoginWithFacebook:(id)sender
{
    FacebookLogin *login = [Authentication mainAuth].facebookLogin;
    login.delegate = self;
    [login login];
    //TODO: maybe release login?
}

- (void)loginSucceeded
{
    [nameField removeFromSuperview];
    [nameField release];
    [pwField removeFromSuperview];
    [pwField release];
    
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

- (void)loginFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error logging in" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [self loginSucceeded]; //TODO: Make the person log in again
}

-(void)pressedMakeNew:(id)sender
{
    [nameField removeFromSuperview];
    [nameField release];
    [pwField removeFromSuperview];
    [pwField release];
    
    
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"NewAccountMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
