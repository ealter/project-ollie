//
//  DrawMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DrawMenu.h"
#import "DrawEnvironment.h"
#import "SandboxScene.h"
#import "Terrain.h"

@implementation DrawMenu

-(void)pressedLarge:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = largeradius;
}

-(void)pressedMedium:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = mediumradius;
}

-(void)pressedSmall:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = smallradius;
}

-(void)pressedEraser:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = -mediumradius;
}

-(void)pressedCheck:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    SandboxScene* scene = [SandboxScene node];

    [parent_node removeChild:parent_node.terrain cleanup:YES];
    [scene.actionLayer addChild:parent_node.terrain];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedClear:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    [parent_node.terrain clear];
}

@end
