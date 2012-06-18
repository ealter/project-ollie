//
//  MainMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "CCBReader.h"
#import "DrawEnvironment.h"
#import "SandboxScene.h"

@implementation MainMenu

-(void)pressedMakeSquares: (id)sender
{
    SandboxScene *scene = [SandboxScene node];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedDraw:(id)sender
{
    CCScene* scene = [DrawEnvironment scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedOptions:(id)sender
{
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"OptionsMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedNewGame:(id)sender
{
    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
    [colorLayer setOpacity:175];
    [self addChild:colorLayer z:1];
    
    CCNode* newnode = [CCBReader nodeGraphFromFile:@"NewGameOverlay.ccbi"];
    [self addChild:newnode];
    [self reorderChild:newnode z:2];
}

@end
