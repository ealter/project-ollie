//
//  NewGameOverlay.m
//  ProjectOllie
//
//  Created by Lion User on 6/18/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "NewGameMenu.h"
#import "cocos2d.h"

@implementation NewGameMenu

-(id)init
{
    if (self=[super init]) {
        CCLayerGradient *gradientLayer = [CCLayerGradient layerWithColor:ccc4(0, 150, 0, 255) fadingTo:ccc4(0, 200, 0, 255) alongVector:ccp(0, -1)];
        [gradientLayer setBlendFunc:(ccBlendFunc) { GL_ONE, GL_ONE_MINUS_SRC_ALPHA }];
        gradientLayer.contentSize = self.contentSize;
        gradientLayer.position  = CGPointMake(0, 0);
        [self addChild:gradientLayer z:-1];
    }
    
    return self;
}

-(void)pressedWithFriend:(id)sender
{
    
}

-(void)pressedWithRandom:(id)sender
{
    
}

-(void)pressedWithSearch:(id)sender
{
    [self transitionToSceneWithFile:@"PlayerSearchScreen.ccbi"];
}

-(void)pressedWithLocal:(id)sender
{
    
}

-(void)pressedCancel:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

@end
