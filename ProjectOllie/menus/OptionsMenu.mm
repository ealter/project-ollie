//
//  OptionsMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsMenu.h"
#import "Authentication.h"
#import "ChangeUserName.h"
#import "cocos2d.h"

@interface OptionsMenu () <ServerAPI_delegate>

@end

@implementation OptionsMenu

-(id)init
{
    if (self = [super init]) {     
        CGRect nameframe = CGRectMake(self.contentSize.height*4/5, self.contentSize.width/2, 150, 30);
        nameField = [self addTextFieldWithFrame:nameframe];
        nameField.text = [Authentication mainAuth].username;
        nameField.delegate = self;
        
        userName = [CCLabelTTF labelWithString: @"Current Username: " fontName:@"Helvetica" fontSize:15];
        userName.anchorPoint = ccp(1,0.5);
        userName.position=ccp(self.contentSize.width*0.5 - nameframe.size.width/2, self.contentSize.height*4/5);
        [self addChild:userName z:1];
    }
    
    return self;
}

-(void)pressedConfirm:(id)sender
{
    NSString *newUsername = nameField.text;
    if(![newUsername isEqualToString:[Authentication mainAuth].username]) {
        ChangeUserName *changeUserName = [[[ChangeUserName alloc]init] autorelease];
        changeUserName.delegate = self;
        [self startActivityIndicator];
        [changeUserName changeUserNameTo:newUsername];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

-(void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi" removeUIViews:[NSArray arrayWithObject:nameField]];
}

- (void)serverOperationSucceeded
{
    [self pressedBack:self];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    [[[[UIAlertView alloc]initWithTitle:@"Error when changing username" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
}

@end
