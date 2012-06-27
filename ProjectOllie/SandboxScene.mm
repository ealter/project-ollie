//
//  SandboxScene.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SandboxScene.h"
#import "cocos2d.h"
#import "ActionLayer.h"
#import "CCBReader.h"
#import "Background.h"
#import "RippleEffect.h"

@implementation SandboxScene

@synthesize actionLayer = _actionLayer;

-(id) init
{
    if (self = [super init]) {
        // 'layer' is an autorelease object.
        self.actionLayer = [ActionLayer node];
        [self setAnchorPoint:ccp(.5,.5)];

        [self addChild:self.actionLayer];
        
        Background *blayer = [Background node];
        [blayer initWithSpeed:0 images:[NSArray arrayWithObject:@"white_clouds.jpeg"]];
        [self addChild:blayer];
        [self reorderChild:blayer z:-100];
        [self.actionLayer.camera.children addObject:blayer];
        
        CCNode *backnode = [CCBReader nodeGraphFromFile:@"ActionMenu.ccbi"];
        [self addChild:backnode];
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCRenderTexture *renderTextureA = [[CCRenderTexture renderTextureWithWidth:s.width height:s.height] retain];
        [renderTextureA begin];
        [self visit];
        [renderTextureA end];
        renderTextureA.position = CGPointMake(s.width, s.height);
        //Shader testy stuff here
        CCSprite *sprite = [CCSprite spriteWithTexture:renderTextureA.sprite.texture];
		sprite.anchorPoint = CGPointMake(0.5, 0.5);
		sprite.position = CGPointMake([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2);
        [self addChild:sprite];
        
        RippleEffect *ripple =[RippleEffect nodeWithTarget:sprite];
        
        [self addChild:ripple z:3];

    }
    return self;
}

@end
