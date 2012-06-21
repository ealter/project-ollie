//
//  NewAccountMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewAccountMenu.h"
#import "CCBReader.h"
#import "AccountCreator.h"

@interface NewAccountMenu () <ServerAPI_delegate>
@property (nonatomic, retain) AccountCreator *accountCreator;
- (void)returnToMenuWithFile:(NSString *)menuName;

@end

@implementation NewAccountMenu
@synthesize emailField, pwField, nameField, cfpwField;
@synthesize accountCreator = _accountCreator;

-(id)init
{
    if(self=[super init])
    {
        CGRect nameframe = CGRectMake(self.contentSize.height*0.5, self.contentSize.width/2-15, 150, 30);
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
        CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);  
        nameField.transform = transform;
        
        CGRect pwframe = CGRectMake(self.contentSize.height*0.35, self.contentSize.width/2-15, 150, 30);
        pwField = [[UITextField alloc]initWithFrame:pwframe];
        pwField.clearsOnBeginEditing = YES;
        pwField.placeholder = @"Password";
        pwField.keyboardType = UIKeyboardTypeDefault;
        pwField.returnKeyType = UIReturnKeyDone;
        pwField.autocorrectionType = UITextAutocorrectionTypeNo;
        pwField.adjustsFontSizeToFitWidth = YES;
        pwField.textColor = [UIColor blackColor];
        [pwField setFont:[UIFont fontWithName:@"Arial" size:14]];
        pwField.backgroundColor = [UIColor whiteColor];
        pwField.borderStyle = UITextBorderStyleRoundedRect;
        pwField.transform = transform;
        pwField.secureTextEntry = YES;
        
        CGRect cfpwframe = CGRectMake(self.contentSize.height*0.2, self.contentSize.width/2-15, 150, 30);
        cfpwField = [[UITextField alloc]initWithFrame:cfpwframe];
        cfpwField.clearsOnBeginEditing = YES;
        cfpwField.placeholder = @"Confirm Password";
        cfpwField.keyboardType = UIKeyboardTypeDefault;
        cfpwField.returnKeyType = UIReturnKeyDone;
        cfpwField.autocorrectionType = UITextAutocorrectionTypeNo;
        cfpwField.adjustsFontSizeToFitWidth = YES;
        cfpwField.textColor = [UIColor blackColor];
        [cfpwField setFont:[UIFont fontWithName:@"Arial" size:14]];
        cfpwField.backgroundColor = [UIColor whiteColor];
        cfpwField.borderStyle = UITextBorderStyleRoundedRect;
        cfpwField.transform = transform;
        cfpwField.secureTextEntry = YES;
        
        CGRect emailframe = CGRectMake(self.contentSize.height*0.65, self.contentSize.width/2-15, 150, 30);
        emailField = [[UITextField alloc]initWithFrame:emailframe];
        emailField.clearsOnBeginEditing = YES;
        emailField.placeholder = @"Email";
        emailField.keyboardType = UIKeyboardTypeDefault;
        emailField.returnKeyType = UIReturnKeyDone;
        emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        emailField.adjustsFontSizeToFitWidth = YES;
        emailField.textColor = [UIColor blackColor];
        [emailField setFont:[UIFont fontWithName:@"Arial" size:14]];
        emailField.backgroundColor = [UIColor whiteColor];
        emailField.borderStyle = UITextBorderStyleRoundedRect;
        emailField.transform = transform;
        
        [nameField setDelegate:self];
        [pwField setDelegate:self];
        [emailField setDelegate:self];
        [cfpwField setDelegate:self];
        
        [[[[CCDirector sharedDirector] view] window] addSubview:nameField];  
        [[[[CCDirector sharedDirector] view] window] addSubview:pwField];
        [[[[CCDirector sharedDirector] view] window] addSubview:emailField];
        [[[[CCDirector sharedDirector] view] window] addSubview:cfpwField];
        
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
    [self.accountCreator createAccountWithUsername:username password:password email:email];
}

- (void)returnToMenuWithFile:(NSString *)menuName
{
    [nameField removeFromSuperview];
    [nameField release];
    [cfpwField removeFromSuperview];
    [cfpwField release];
    [pwField removeFromSuperview];
    [pwField release];
    [emailField removeFromSuperview];
    [emailField release];
    
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:menuName];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedCancel:(id)sender
{
    [self returnToMenuWithFile:@"LoginScreen.ccbi"];
}

- (void)serverOperationSucceeded
{
    [self returnToMenuWithFile:@"MainMenu.ccbi"];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error creating account" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
