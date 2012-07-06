//
//  ActionMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ActionMenu.h"

@implementation ActionMenu

-(void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

@end
