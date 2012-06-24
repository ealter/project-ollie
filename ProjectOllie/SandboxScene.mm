//
//  SandboxScene.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SandboxScene.h"
#import "ActionLayer.h"
#import "CCBReader.h"
#import "Background.h"


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
        [blayer initWithSpeed:3 images:[NSArray arrayWithObject:@"white_clouds.jpeg"]];
        [self addChild:blayer];
        [self reorderChild:blayer z:-100];
        [self.actionLayer.camera.children addObject:blayer];
        
        CCNode *backnode = [CCBReader nodeGraphFromFile:@"ActionMenu.ccbi"];
        [self addChild:backnode];
        [self reorderChild:backnode z:2];
        
        
        
    }
    return self;
}

@end
