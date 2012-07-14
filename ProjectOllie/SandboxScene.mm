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
        
        NSString *backgroundNames[] = {@"background_layer1.png", @"background_layer1_tree.png", @"background_layer1_rocksleaves.png", @"background_layer1_middleplants.png"};
        float parallaxRatios[] = {0.2, 0.4, 0.6, 0.8};
        assert(sizeof(backgroundNames)/sizeof(*backgroundNames) == sizeof(parallaxRatios)/sizeof(*parallaxRatios));
        for(int i=0; i<sizeof(backgroundNames)/sizeof(*backgroundNames); i++) {
            SpriteParallax *blayer = [[SpriteParallax alloc] initWithFile:backgroundNames[i]];
            blayer.parallaxRatio = parallaxRatios[i];
            [actionNode addChild:blayer];
            blayer.anchorPoint = CGPointZero;
            //blayer.position = ccpMult(ccpFromSize(self.contentSize), 0.5);
            [self.actionLayer.camera.children addObject:blayer];
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
