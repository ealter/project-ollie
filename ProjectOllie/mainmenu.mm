//
//  mainmenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/1/12.
//  Copyright 2012 hi ku llc All rights reserved.
//

#import "mainmenu.h"
#import "CCBReader.h"
#import "SandboxLayer.h"
#import "DrawEnvironment.h"
#import "Background.h"

@implementation mainmenu

-(void)pressedMakeSquares: (id)sender
{
    CCScene* scene = [SandboxLayer scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedDraw:(id)sender
{
    CCScene* scene = [DrawEnvironment scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
