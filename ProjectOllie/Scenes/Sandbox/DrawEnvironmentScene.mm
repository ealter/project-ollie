//
//  DrawEnvironmentScene.m
//  ProjectOllie
//
//  Created by Steve "The Best" Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "DrawEnvironmentScene.h"

@implementation DrawEnvironmentScene

//Create empty environment for drawing new land
-(id) init
{
    self = [self initWithEnvironment:[GWEnvironment node]];
    return self;
}

//For editing land
-(id) initWithEnvironment:(GWEnvironment *)environment
{
    if (self = [super initWithEnvironment:environment])
    {
        
        
        //Add the brush and setting button touch layer
        
        
        
        //Add the drawing touch layer
        
    }
    return self;
}

@end
