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
#import "RippleEffect.h"
#import "SpriteParallax.h"

#define array_length(name) (sizeof(name)/sizeof(*(name)))

@implementation SandboxScene {
    RippleEffect *ripple;
}
@synthesize actionLayer = _actionLayer;

-(id) init
{
    if (self = [super init]) {
        /* Set up action layer (where action occurs */
        self.actionLayer = [ActionLayer node];
        CCNode* actionNode = [CCNode node];
        
        /* Set up parallax */
        NSString *backgroundNames[] = {@"background_layer1.png", @"background_layer1_tree.png", @"background_layer1_rocksleaves.png", @"background_layer1_middleplants.png"};
        float parallaxRatios[] = {0.2, 0.4, 0.6, 0.8};
        assert(array_length(backgroundNames) == array_length(parallaxRatios));
        for(int i=0; i<array_length(backgroundNames); i++) {
            SpriteParallax *blayer = [[SpriteParallax alloc] initWithFile:backgroundNames[i]];
            blayer.parallaxRatio = parallaxRatios[i];
            blayer.anchorPoint = CGPointZero;
            //blayer.position = ccpMult(ccpFromSize(self.contentSize), 0.5);
            
            //add as children to proper nodes
            [actionNode addChild:blayer];
            [self.actionLayer.camera.children addObject:blayer];
        }
        
        [actionNode addChild:self.actionLayer];
        
        [self addChild:actionNode];

        /* Set up sandbox scene properties */
        [self setAnchorPoint:ccp(.5,.5)];
//        CCNode *backnode = [CCBReader nodeGraphFromFile:@"ActionMenu.ccbi"];
//        [self addChild:backnode];
//        [self reorderChild:backnode z:1000];
    }
    return self;
}

@end
