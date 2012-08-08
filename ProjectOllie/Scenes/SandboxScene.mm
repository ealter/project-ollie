//
//  SandboxScene.m
//  ProjectOllie
//
//  Created by Lion Sam Zeckendorf on 6/6/12.
//  Copyright 2012 hi ku llc All rights reserved.
//

#import "SandboxScene.h"
#import "cocos2d.h"
#import "ActionLayer.h"
#import "CCBReader.h"
#import "RippleEffect.h"
#import "SpriteParallax.h"
#import "GWWater.h"
#import "GameConstants.h"

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
        GWCamera* camera = [[GWCamera alloc] initWithScreenDimensions:[[CCDirector sharedDirector]winSizeInPixels]];
        self.actionLayer = [[ActionLayer alloc] initWithCamera:camera];
        CCNode* actionNode = [CCNode node];
        
        /* Set up parallax */
        [self initBackgroundsWithBasename:@"ice" actionNode:actionNode camera:self.actionLayer.camera];
        
        GWWater* waterFront = [[GWWater alloc] initWithCamera:camera z:(-.25*PTM_RATIO)];
        GWWater* waterBack = [[GWWater alloc] initWithCamera:camera z:(.25*PTM_RATIO)];
        
        /* Set up sandbox scene properties */
        //[self setAnchorPoint:ccp(.5,.5)];
        CCNode *backnode = [CCBReader nodeGraphFromFile:@"ActionMenu.ccbi"];
        
        //Add all of the layers in the order we would like them to render
        [actionNode addChild:backnode];
        [actionNode addChild:waterBack];
        [actionNode addChild:self.actionLayer];
        [actionNode addChild:waterFront];
        [self addChild:actionNode];
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
        if (!([[NSBundle mainBundle] pathForResource:backgroundNameWithoutExtension ofType:fileExtension])) continue;
        NSString *backgroundName = [backgroundNameWithoutExtension stringByAppendingPathExtension:fileExtension];
        SpriteParallax *blayer = [[SpriteParallax alloc] initWithFile:backgroundName camera:camera];
        blayer.z = PTM_RATIO/parallaxRatios[i];
        blayer.anchorPoint = CGPointZero;
        blayer.position = CGPointZero;
        blayer.scale = 10;
        [actionNode addChild:blayer];
    }
}

@end
