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
#import "Background.h"
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
        Background *middlePlants = [[Background node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1_middleplants.png"]];
        Background *rockSleaves  = [[Background node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1_rocksleaves.png"]];
        Background *tree = [[Background node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1_tree.png"]];
        Background *blayer = [[Background node] initWithSpeed:0 images:[NSArray arrayWithObject:@"background_layer1.png"]];
        
        CCNode* actionNode = [CCNode node];
        NSArray *backgrounds = [NSArray arrayWithObjects:blayer, tree, middlePlants, rockSleaves, nil];
        for(Background *background in backgrounds) {
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
