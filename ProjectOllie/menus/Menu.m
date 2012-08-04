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
#import "IOS_Versions.h"

@implementation Menu

@synthesize activityIndicator = _activityIndicator;

- (void)transitionToSceneWithFile:(NSString *)sceneName
{
    [self stopActivityIndicator];
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:sceneName];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
    //[[CCDirector sharedDirector] pushScene:scene];
}

- (void)startActivityIndicator
{
    if(!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        UIView *mainView = [CCDirector sharedDirector].view;
        if([IOS_Versions iOS_5])
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
