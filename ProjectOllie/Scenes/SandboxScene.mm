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

@interface SandboxScene () {
    RippleEffect *ripple;
}

- (void)initBackgroundsWithBasename:(NSString *)baseImageName actionNode:(CCNode *)actionNode camera:(GWCamera *)camera;

@end

@implementation SandboxScene

@synthesize actionLayer = _actionLayer;

-(id) init
{
    if (self = [super init]) {
        /* Set up action layer (where action occurs */
        self.actionLayer = [ActionLayer node];
        CCNode* actionNode = [CCNode node];
        
        /* Set up parallax */
        [self initBackgroundsWithBasename:@"ice" actionNode:actionNode camera:self.actionLayer.camera];
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

- (void)initBackgroundsWithBasename:(NSString *)baseImageName actionNode:(CCNode *)actionNode camera:(GWCamera *)camera
{
    const int numBackgroundLayers = 4;
    float parallaxRatios[] = {0.2, 0.4, 0.6, 0.8};
    assert(numBackgroundLayers == array_length(parallaxRatios));
    for(int i=0; i<numBackgroundLayers; i++) {
        static NSString *fileExtension = @"png";
        NSString *backgroundNameWithoutExtension = [NSString stringWithFormat:@"%@_layer%d", baseImageName, i+1, nil];
        if([[NSBundle mainBundle] pathForResource:backgroundNameWithoutExtension ofType:fileExtension] == nil)
            continue; //The image doesn't exist
        NSString *backgroundName = [backgroundNameWithoutExtension stringByAppendingPathExtension:fileExtension];
        SpriteParallax *blayer = [[SpriteParallax alloc] initWithFile:backgroundName];
        blayer.parallaxRatio = parallaxRatios[i];
        blayer.anchorPoint = CGPointZero;
        blayer.anchorPoint = ccp(.125f,.125f);
        [actionNode addChild:blayer];
        [camera.children addObject:blayer];
    }
}

@end
