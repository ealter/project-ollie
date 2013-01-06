//
//  GameScene.h
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

#import "EnvironmentScene.h"
#import "CCLayer.h"
#import "Box2D.h"

class GLESDebugDraw;

@interface GameScene : EnvironmentScene

/* Properties */

@property (nonatomic) b2World* world;                   // Realistically simulates fun

@property (nonatomic) GLESDebugDraw* m_debugDraw;		// For seeing what box2d is thinking

//Array of characters in this game

//The currently selected character if there is one

//All of the GW phys sprites in the world

/* Methods */

-(id) initWithEnvironment:(GWEnvironment *)environment;

@end


