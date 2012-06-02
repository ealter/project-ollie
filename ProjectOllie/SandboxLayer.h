//
//  SandboxLayer.h
//  ProjectOllie
//
//  Created by Lion User on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface SandboxLayer : CCLayer
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
