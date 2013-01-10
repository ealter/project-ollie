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
#import "GWContactListener.h"
#import "GameConstants.h"
#import "GLES-Render.h"
#import "cocos2d.h"


@implementation GameScene
@synthesize world = _world;
@synthesize m_debugDraw = _m_debugDraw;

- (id)initWithEnvironment:(GWEnvironment *)environment
{
    if (self = [super initWithEnvironment:environment])
    {
        //Create fun
        self.world = new b2World(b2Vec2(0, -2.f));
        self.world->SetAllowSleeping(true);
        self.world->SetContinuousPhysics(true);
        GWContactListener *_contactListener = new GWContactListener();
        self.world->SetContactListener(_contactListener);
        
        self.m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        self.world->SetDebugDraw(self.m_debugDraw);
        
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        //   	flags += b2Draw::e_jointBit;
        //		flags += b2Draw::e_aabbBit;
        //		flags += b2Draw::e_pairBit;
        //		flags += b2Draw::e_centerOfMassBit;
        self.m_debugDraw->SetFlags(flags);		

        
        //Add a panning touch layer in the world hud
        [self.worldHUD addChild:[self.gwCamera createPanTouchLayer]];
        
        //Add the terrain (only physical piece not owned by this class) to the box2d world
        [self.environment.terrain addToWorld:self.world];
        
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
    self.world->Step(dt, velocityIterations, positionIterations);
    
    [self.gwCamera update:dt];
}

-(void) draw
{
    [super draw];
    
    /* Box2d debug drawing */
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
     kmGLPushMatrix();
     self.world->DrawDebugData();	
     kmGLPopMatrix();
    
}



-(void) dealloc
{
    delete self.world;
    self.world = NULL;
    
    delete self.m_debugDraw;
    self.m_debugDraw = NULL;
}	


@end









