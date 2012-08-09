//
//  GameScene.h
//  ProjectOllie
//
//  Created by lion eater Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "EnvironmentScene.h"
#import "Box2D.h"

class GLESDebugDraw;

@interface GameScene : EnvironmentScene

/* Properties */

@property (nonatomic) b2World* world;                   // Realistically simulates fun

@property (nonatomic) GLESDebugDraw *m_debugDraw;		// For debugging box2d

//Array of characters in this game

//The currently selected character if there is one

//All of the GW phys sprites in the world

/* Methods */

-(id) initWithEnvironment:(GWEnvironment *)environment;

@end
