//
//  NewAccountMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewAccountMenu.h"
#import "CCBReader.h"

@implementation NewAccountMenu
@synthesize emailField, pwField, nameField;
-(id)init
{
    if(self=[super init])
    {
        CGRect nameframe = CGRectMake(self.contentSize.height*2/5, self.contentSize.width/2-15, 150, 30);
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
        
        CGRect pwframe = CGRectMake(self.contentSize.height/5, self.contentSize.width/2-15, 150, 30);
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
        
        CGRect emailframe = CGRectMake(self.contentSize.height*3/5, self.contentSize.width/2-15, 150, 30);
        emailField = [[UITextField alloc]initWithFrame:emailframe];
        emailField.clearsOnBeginEditing = YES;
        emailField.placeholder = @"email";
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
        
        [[[[CCDirector sharedDirector] view] window] addSubview:nameField];  
        [[[[CCDirector sharedDirector] view] window] addSubview:pwField];
        [[[[CCDirector sharedDirector] view] window] addSubview:emailField];
    }
    
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

-(void)pressedMake:(id)sender
{
    
}

-(void)pressedCancel:(id)sender
{
    [nameField removeFromSuperview];
    [nameField release];
    [pwField removeFromSuperview];
    [pwField release];
    [emailField removeFromSuperview];
    [emailField release];
    
    
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"LoginScreen.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
