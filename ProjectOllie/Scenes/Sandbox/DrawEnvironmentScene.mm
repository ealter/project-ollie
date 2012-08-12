//
//  DrawEnvironmentScene.m
//  ProjectOllie
//
//  Created by Steve "The Best" Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "DrawEnvironmentScene.h"

@implementation DrawEnvironmentScene

//Create default init for drawing new land
-(id) init
{
    self = [super initWithEnvironment:[GWEnvironment node]];
    return self;
}

//For editing land
-(id) initWithEnvironment:(GWEnvironment *)environment
{
    self = [super initWithEnvironment:environment];
    return self;
}

@end
