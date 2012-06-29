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
        self.actionLayer = [ActionLayer node];
        [self setAnchorPoint:ccp(.5,.5)];

        [self addChild:self.actionLayer];
        
        Background *blayer = [[Background node] initWithSpeed:0 images:[NSArray arrayWithObject:@"white_clouds.jpeg"]];
        [self addChild:blayer];
        [self reorderChild:blayer z:-100];
        [self.actionLayer.camera.children addObject:blayer];
        
        CCNode *backnode = [CCBReader nodeGraphFromFile:@"ActionMenu.ccbi"];
        [self addChild:backnode];
        
        
        
        //RippleEffect *ripple = [RippleEffect nodeWithParent:self];
    }
    return self;
}

@end
