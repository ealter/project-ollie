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
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:sceneName];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
