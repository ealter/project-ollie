//
//  EnvironmentScene.m
//  ProjectOllie
//
//  Created by lion hunter Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//
//  This is the most basic scene that contains an environment with a camera and HUD
//  Any kind of scene that involves interacting with an environment should extend this

#import "EnvironmentScene.h"
#include "CCDirector.h"

@implementation EnvironmentScene

@synthesize environment = _environment;
@synthesize camera = _camera;
@synthesize worldHUD = _worldHUD;
@synthesize screenHUD = _screenHUD;

-(id)initWithEnvironment:(GWEnvironment *)environment
{
    if (self = [super init])
    {
        _environment = environment;
        _camera = [[GWCamera alloc] initWithScreenDimensions:[[CCDirector sharedDirector]winSizeInPixels]];
        [_environment setCamera:_camera];
        
        _worldHUD = [CCLayer node];
        
        
        [self addChild:_environment];
        [self addChild:_worldHUD];
        [self addChild:_screenHUD];
    }
    return self;
}

@end
