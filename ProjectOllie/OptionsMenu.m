//
//  OptionsMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsMenu.h"
#import "CCBReader.h"

@implementation OptionsMenu

-(void)pressedBack:(id)sender
{
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
