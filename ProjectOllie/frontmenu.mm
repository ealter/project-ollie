//
//  frontmenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "frontmenu.h"
#import "CCBReader.h"
#import "SandboxLayer.h"
#import "DrawEnvironment.h"
#import "SandboxScene.h"

@implementation frontmenu

-(void)pressedMakeSquares: (id)sender
{
    SandboxScene *scene = [SandboxScene node];
    //CCScene* scene = [SandboxLayer scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedDraw:(id)sender
{
    CCScene* scene = [DrawEnvironment scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
