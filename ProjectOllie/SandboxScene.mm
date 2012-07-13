//
//  SandboxScene.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/6/12.
//  Copyright 2012 hi ku llc All rights reserved.
//

#import "SandboxScene.h"
#import "cocos2d.h"
#import "ActionLayer.h"
#import "CCBReader.h"
#import "ScrollingBackground.h"
#import "RippleEffect.h"

@implementation SandboxScene {
    RippleEffect *ripple;
}
@synthesize actionLayer = _actionLayer;

-(id) init
{
    if (self = [super init]) {
        /* Set up action layer (where action occurs */
        self.actionLayer = [ActionLayer node];
        ScrollingBackground *middlePlants = [[ScrollingBackground node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1_middleplants.png"]];
        ScrollingBackground *rockSleaves  = [[ScrollingBackground node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1_rocksleaves.png"]];
        ScrollingBackground *tree         = [[ScrollingBackground node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1_tree.png"]];
        ScrollingBackground *blayer       = [[ScrollingBackground node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1.png"]];
        
        CCNode* actionNode = [CCNode node];
        //NSArray *backgrounds = [NSArray arrayWithObjects:blayer, tree, middlePlants, rockSleaves, nil];
        NSArray *backgrounds = [NSArray arrayWithObject:tree];
        for(ScrollingBackground *background in backgrounds) {
            [self.actionLayer.camera.children addObject:background];
            [actionNode addChild:background];
        }
        [actionNode addChild:self.actionLayer];
        
        [self addChild:actionNode];

        /* Set up sandbox scene properties */
        [self setAnchorPoint:ccp(.5,.5)];
        CCNode *backnode = [CCBReader nodeGraphFromFile:@"ActionMenu.ccbi"];
        [self addChild:backnode];
        [self reorderChild:backnode z:1000];
    }
    return self;
}

@end
