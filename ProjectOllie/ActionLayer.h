//
//  ActionLayer.h
//  ProjectOllie
//
//  Created by Lion User on 6/1/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "GLES-Render.h"

@class GWCamera;

@interface ActionLayer : CCLayer <UIGestureRecognizerDelegate>
{

	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    CGSize s;
    CCParallaxNode* parallax_;
}

@property (strong, nonatomic) CCNode* center;
@property (strong, nonatomic) GWCamera* camera;
@property (assign, nonatomic) CGSize windowSize;


// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

// adds terrain to build
//-(void) addTerrain:(CGPoint*)points;


@end
