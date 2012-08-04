//
//  OptionsMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/18/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "OptionsMenu.h"
#import "Authentication.h"
#import "ChangeUserName.h"
#import "cocos2d.h"

@interface OptionsMenu () <ServerAPI_delegate>

@end

@implementation OptionsMenu

- (id)init
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

- (void)pressedConfirm:(id)sender
{
    NSString *newUsername = nameField.text;
    if(![newUsername isEqualToString:[Authentication mainAuth].username]) {
        ChangeUserName *changeUserName = [[ChangeUserName alloc] init];
        changeUserName.delegate = self;
        [self startActivityIndicator];
        [changeUserName changeUserNameTo:newUsername];
    }
}

- (NSArray *)textFields
{
    return [NSArray arrayWithObject:nameField];
}

- (void)pressedChangePassword:(id)sender
{
    [self transitionToSceneWithFile:@"PasswordChangeScreen.ccbi"];
}

-(void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

- (void)serverOperationSucceededWithData:(id)data
{
    [self pressedBack:self];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    [[[UIAlertView alloc]initWithTitle:@"Error when changing username" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

@end
