//
//  ActionLayer.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/1/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import <GameKit/GameKit.h>
// When you import this file, you import all the cocos2d classes
#import "GLES-Render.h"
#import "GWCamera.h"

//Action Layer is different from a regular layer in that it has a camera that follows it
//And it keeps track of parallax brothers in a scene
@interface ActionLayer : CCLayer <CameraObject>
{

	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
}

@property (strong, nonatomic) GWCamera* camera;//camera that watches the action

@property (strong, nonatomic) NSMutableArray* parallaxElements; //the elements it updates the position of

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;



@end
