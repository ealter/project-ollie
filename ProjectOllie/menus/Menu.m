//
//  Menu.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/22/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Menu.h"
#import "cocos2d.h"
#import "CCBReader.h"

@implementation Menu

@synthesize activityIndicator = _activityIndicator;

- (void)transitionToSceneWithFile:(NSString *)sceneName removeUIViews:(NSArray *)uiviews
{
    if(uiviews) {
        for(UIView *view in uiviews) {
            if([view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
            }
            [view release];
        }
    }
    [self stopActivityIndicator];
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:sceneName];
    //Disabled temp cause of poor shader interaction
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
    [[CCDirector sharedDirector] pushScene:scene];
}

- (UITextField *)addTextFieldWithFrame:(CGRect)frame
{
    UITextField *field = [[UITextField alloc]initWithFrame:frame];
    field.clearsOnBeginEditing = NO;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.adjustsFontSizeToFitWidth = YES;
    [field setFont:[UIFont fontWithName:@"Arial" size:14]];
    field.backgroundColor = [UIColor whiteColor];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.transform = CGAffineTransformMakeRotation(M_PI/2);
    field.frame = CGRectMake(field.frame.origin.x-field.frame.size.height/2, field.frame.origin.y- field.frame.size.width/2, field.frame.size.width, field.frame.size.height);   
    [[CCDirector sharedDirector].view.window addSubview:field];
    return field;
}

- (void)startActivityIndicator
{
    if(!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        UIView *mainView = [CCDirector sharedDirector].view;
        self.activityIndicator.color = [UIColor grayColor];
        self.activityIndicator.center = mainView.center;
        [mainView addSubview:self.activityIndicator];
    }
    [self.activityIndicator startAnimating];
}

- (void)stopActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

@end
