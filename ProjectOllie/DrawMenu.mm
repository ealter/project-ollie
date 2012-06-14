//
//  DrawMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DrawMenu.h"
#import "DrawEnvironment.h"

@implementation DrawMenu

-(void)pressedLarge:(id)sender
{
    DrawEnvironment *lols = (DrawEnvironment *)[self parent];
    lols.brushradius = largeradius;
}

-(void)pressedMedium:(id)sender
{
    DrawEnvironment *lols = (DrawEnvironment *)[self parent];
    lols.brushradius = mediumradius;
}

-(void)pressedSmall:(id)sender
{
    DrawEnvironment *lols = (DrawEnvironment *)[self parent];
    lols.brushradius = smallradius;
}

-(void)pressedEraser:(id)sender
{
    DrawEnvironment *lols = (DrawEnvironment *)[self parent];
    lols.brushradius = -smallradius;
}

-(void)pressedCheck:(id)sender
{
    
}

-(void)pressedClear:(id)sender
{
    
}

@end
