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

@implementation EnvironmentScene

@synthesize environment = _environment;
@synthesize camera = _camera;
@synthesize worldHUD = _worldHUD;
@synthesize screenHUD = _screenHUD;

@end
