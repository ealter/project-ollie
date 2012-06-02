//
//  mainmenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "mainmenu.h"
#import "CCBReader.h"
#import "SandboxLayer.h"

@implementation mainmenu

-(void)pressedMe: (id)sender
{
    CCScene* scene = [SandboxLayer scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
