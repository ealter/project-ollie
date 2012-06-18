//
//  NewGameOverlay.m
//  ProjectOllie
//
//  Created by Lion User on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewGameOverlay.h"
#import "CCBReader.h"

@implementation NewGameOverlay

-(void)pressedWithFriend:(id)sender
{
    
}

-(void)pressedWithRandom:(id)sender
{
    
}

-(void)pressedWithSearch:(id)sender
{
    
}

-(void)pressedWithLocal:(id)sender
{
    
}

-(void)pressedCancel:(id)sender
{
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.1f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
