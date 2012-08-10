//
//  GWEnvironment.m
//  ProjectOllie
//
//  Created by l. ion battery Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "GWEnvironment.h"

@implementation GWEnvironment


@synthesize setting     = _setting;
@synthesize actionLayer = _actionLayer;
@synthesize backWater   = _backWater;
@synthesize frontWater  = _frontWater;
@synthesize terrain     = _terrain;
@synthesize backdrop    = _backdrop;


+(void) initialize
{
    
}

-(id) init
{
    if (self = [super init])
    {
        _setting = dirt;
        _terrain = [Terrain node];
    }
    return self;
}

-(id) initWithSetting:(Setting)setting terrain:(Terrain*)terrain
{
    if (self = [super init])
    {
        _setting = setting;
        _terrain = terrain;
    }
    return self;
}


-(id) setCamera:(GWCamera*)camera
{
    //Set the camera for every layer
    self.frontWater.camera = camera;
    self.backWater.camera = camera;
    self.frontWater.camera = camera;
    self.frontWater.camera = camera;
    self.frontWater.camera = camera;
    self.frontWater.camera = camera;
    
}


@end
