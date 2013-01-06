//
//  GWEnvironment.m
//  ProjectOllie
//
//  Created by Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "GWEnvironment.h"
#import "GameConstants.h"
#import "cocos2d.h"

@implementation GWEnvironment


@synthesize setting     = _setting;
@synthesize frontWater  = _frontWater;
@synthesize actionLayer = _actionLayer;
@synthesize terrain     = _terrain;
@synthesize backWater   = _backWater;
@synthesize backgroundNear = _backgroundNear;
@synthesize backgroundFar  = _backgroundFar;
@synthesize backdrop    = _backdrop;
@synthesize shadowMap   = _shadowMap;

const ccColor4F waterColor = ccc4f(0.f, 0.1f, .9f, 1.f);
const ccColor4F lavaColor = ccc4f(0.f, 0.1f, .9f, 1.f);

-(id) init
{
    self = [self initWithSetting:environment_dirt terrain:[Terrain node]];
    return self;
}

-(id) initWithSetting:(EnvironmentSetting)setting terrain:(Terrain*)terrain
{
    if (self = [super init])
    {
        _terrain = terrain;
        
        //Make layers
        _frontWater = [[GWWater alloc] initWithCamera:NULL z:(-.25*PTM_RATIO)];
        _actionLayer = [[GWPerspectiveLayer alloc] initWithCamera:NULL z:0];
        _backWater = [[GWWater alloc] initWithCamera:NULL z:(.25*PTM_RATIO)];
        _backgroundNear = [[GWPerspectiveLayer alloc] initWithCamera:NULL z:.4f*PTM_RATIO];
        _backgroundFar = [[GWPerspectiveLayer alloc] initWithCamera:NULL z:.8*PTM_RATIO];
        _backdrop = [[GWPerspectiveLayer alloc] initWithCamera:NULL z:1.4*PTM_RATIO];
        CGSize s = [[CCDirector sharedDirector] winSizeInPixels];
        _shadowMap = [CCRenderTexture renderTextureWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_A8];
        
        [_actionLayer addChild:terrain];
        
        //Add every layer from back to front
        [self addChild:_backdrop];
        [self addChild:_backgroundFar];
        [self addChild:_backgroundNear];
        [self addChild:_backWater];
        [self addChild:_actionLayer];
        [self addChild:_frontWater];
        
        [self setSetting:environment_dirt];
    }
    return self;
}

-(id) initWithSetting:(EnvironmentSetting)setting terrain:(Terrain*)terrain camera:(GWCamera*)camera
{
    //TODO
    DebugLog(@"This has not yet been implemented");
    return [self initWithSetting:setting terrain:terrain];
}

-(void) setCamera:(GWCamera*)camera
{
    //Set the camera for every layer
    self.frontWater.camera = camera;
    self.backWater.camera = camera;
    self.actionLayer.camera = camera;
    self.backdrop.camera = camera;
    self.backgroundNear.camera = camera;
    self.backgroundFar.camera = camera;
}

-(void) setSetting:(EnvironmentSetting)setting
{
    _setting = setting;
    //Clear the background nodes to place the correct sprites inside
    [_backdrop removeAllChildrenWithCleanup:YES];
    [_backgroundFar removeAllChildrenWithCleanup:YES];
    [_backgroundNear removeAllChildrenWithCleanup:YES];
    switch (setting) {
        case environment_dirt:
        {
            [_terrain setTexture:[[CCTextureCache sharedTextureCache] addImage:@"lava.png"]];
            [_terrain setStrokeColor:ccc4f(1.0f, 0.6f, 0.4f, 1.0f)];
            
            [_backdrop addChild:[[CCSprite alloc] initWithFile:@"jungle_layer1-hd.png"]];
            [_backgroundFar addChild:[[CCSprite alloc] initWithFile:@"jungle_layer2-hd.png"]];
            [_backgroundNear addChild:[[CCSprite alloc] initWithFile:@"jungle_layer3-hd.png"]];
            [_backWater setColor:waterColor];
            [_frontWater setColor:waterColor];
            break;
        }
        case environment_rocks:
        {   
            
            [_backWater setColor:waterColor];
            [_frontWater setColor:waterColor];
            break;
        }   
        case environment_ice:
        {   
            [_terrain setTexture:[[CCTextureCache sharedTextureCache] addImage:@"snow.png"]];
            [_terrain setStrokeColor:ccc4f(1.0f, 1.0f, 1.0f, 1.0f)];
            
            [_backdrop addChild:[[CCSprite alloc] initWithFile:@"ice_layer1.png"]];
            [_backgroundFar addChild:[[CCSprite alloc] initWithFile:@"ice_layer2.png"]];
            [_backgroundNear addChild:[[CCSprite alloc] initWithFile:@"ice_layer3.png"]];
            [_backWater setColor:waterColor];
            [_frontWater setColor:waterColor];
            break;
        }   
        case environment_lava:
        {
            
            [_backWater setColor:lavaColor];
            [_frontWater setColor:lavaColor];
            break;
        }   
        default:
            assert(false);
    }
}


-(void) visit
{
    [self sortAllChildren];
    
    ccArray *arrayData = children_->data;
    NSUInteger i = 0;
    
    for( ; i < arrayData->num; i++ ) {
        CCNode *child = arrayData->arr[i];
        if ([child isKindOfClass:[GWPerspectiveLayer class]])
            [(GWPerspectiveLayer*)child collectShadow:_shadowMap];
        CCLOG(@"THE LOOP IS EFFECTIVE");
    }
    
    [super visit];
}

@end
