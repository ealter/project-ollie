//
//  backoverlay.m
//  ProjectOllie
//
//  Created by Lion User on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "backoverlay.h"
#import "CCBReader.h"

@implementation backoverlay

-(void)pressedBack:(id)sender
{
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"frontmenu.ccbi"];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
