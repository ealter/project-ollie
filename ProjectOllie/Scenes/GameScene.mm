//
//  GameScene.mm
//  ProjectOllie
//
//  Created by lion eater Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//
//  This is the base class for any environment scene that has movable
//  characters in an interactive and fun environment. Any kind of version
//  of the game (battling, missions, weapon testing) should derive from
//  this class. Anything that is meant to interact with characters and 
//  world items should call back to this base class so that it works in any 
//  version of this game.

#import "GameScene.h"

@implementation GameScene
@synthesize world = _world;
@synthesize m_debugDraw = _m_debugDraw;

- (id)initWithEnvironment:(GWEnvironment *)environment
{
    if (self = [super initWithEnvironment:environment])
    {
        
        //Add a panning touch layer in the world hud
        [self.worldHUD addChild:[self.gwCamera createPanTouchLayer]];
        
        //Add the terrain to the physics world
        
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)dt
{
    //We are using a fixed timestep
    dt = 1.0f/60.0f;
    
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
//    self.world->Step(dt, velocityIterations, positionIterations);
    
    [self.gwCamera update:dt];
}


@end









