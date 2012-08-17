//
//  DrawEnvironmentScene.m
//  ProjectOllie
//
//  Created by Steve "The Best" Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "DrawEnvironmentScene.h"
#import "CCBReader.h"
#import "DrawMenu.h"
#import "SandboxScene.h"
#import "GameScene.h"
#import "ActionLayer.h"
#import "cocos2d.h"
#import "CCDirector.h"
#import "GameConstants.h"
#import "HMVectorNode.h"

@interface DrawEnvironmentScene () <DrawMenu_delegate>

@end

@implementation DrawEnvironmentScene
{
    DrawTouchLayer* drawTouchLayer;
}

//Create empty environment for drawing new land
-(id) init
{
    self = [self initWithEnvironment:[GWEnvironment node]];
    return self;
}

//For editing land
-(id) initWithEnvironment:(GWEnvironment *)environment
{
    if (self = [super initWithEnvironment:environment])
    {
        //Add the drawing touch layer
        drawTouchLayer = [[DrawTouchLayer alloc] initWithEnvironmentScene:self];
        [[self worldHUD] addChild:drawTouchLayer];
        drawTouchLayer.isTouchEnabled = YES;
        
        //Add the brush and setting button touch layer
        DrawMenu *buttons = (DrawMenu *)[CCBReader nodeGraphFromFile:@"DrawMenu.ccbi"];
        assert([buttons isKindOfClass:[DrawMenu class]]);
        buttons.delegate = self;
        [[self screenHUD] addChild:buttons];
        
    }
    return self;
}

- (void)DrawMenu_setBrushRadius:(CGFloat)radius
{
    drawTouchLayer.brushradius = radius;
}

- (void)DrawMenu_clearDrawing
{
    [self.environment.terrain clear];
}

- (void)DrawMenu_doneDrawing
{
    [self removeChild:self.environment cleanup:YES];
    GameScene *scene = [[GameScene alloc] initWithEnvironment:self.environment];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccBLACK]];
}

@end


@implementation DrawTouchLayer
{
    EnvironmentScene* envScene;
}

//Margins for drawing
const float kMarginX = .2f;
const float kMarginY = .2f;

@synthesize brushradius = _brushradius;

- (id) initWithEnvironmentScene:(EnvironmentScene*)des
{
    if (self = [super init])
    {
        //Know the environment for touch callbacks
        envScene = des;
        
        //Radius of the selected brush in meters
        _brushradius = smallradius;
        
        //Create dotted line for drawing border
        HMVectorNode* border = [HMVectorNode node];
        CGPoint a = ccpMult(ccp(kMarginX, kMarginY), PTM_RATIO);
        CGPoint b = ccpMult(ccp(kMarginX, WORLD_HEIGHT - kMarginY), PTM_RATIO);
        CGPoint c = ccpMult(ccp(WORLD_WIDTH - kMarginX, WORLD_HEIGHT - kMarginY), PTM_RATIO);
        CGPoint d = ccpMult(ccp(WORLD_WIDTH - kMarginX, kMarginY), PTM_RATIO);
        [border drawDottedSegmentFrom:a to:b radius:5.f divisions:WORLD_HEIGHT*2];
        [border drawDottedSegmentFrom:b to:c radius:5.f divisions:WORLD_WIDTH*2];
        [border drawDottedSegmentFrom:c to:d radius:5.f divisions:WORLD_HEIGHT*2];
        [border drawDottedSegmentFrom:d to:a radius:5.f divisions:WORLD_WIDTH*2];
        [border setColor:ccc4f(1, 1, 1, 0.5f)];
        [self addChild:border];
    }
    return self;
}

//Convert touch point to meters and bound in world
- (CGPoint)transformTouchLocationFromTouchView:(CGPoint)location
{
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    //Convert points to meters because terrain is in meters
    location.x /= PTM_RATIO;
    location.y /= PTM_RATIO;
    
    //Bound by margins
    float minToEdge = fabs(self.brushradius);
    if (self.brushradius < 0) minToEdge -= 0.1f;
    
    if (location.x < kMarginX + minToEdge) 
        location.x = kMarginX + minToEdge;
    
    if (location.x > WORLD_WIDTH - kMarginX - minToEdge) 
        location.x = WORLD_WIDTH - kMarginX - minToEdge;
    
    if (location.y < kMarginY + minToEdge)
        location.y = kMarginY + minToEdge;
    
    if (location.y > WORLD_HEIGHT - kMarginY - minToEdge) 
        location.y = WORLD_HEIGHT - kMarginY - minToEdge;
    
    return location;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        //Get touch locations in world meters
        CGPoint location = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        [envScene.environment.terrain clipCircle:_brushradius>0 WithRadius:fabs(_brushradius) x:location.x y:location.y];
    }
    
    [envScene.environment.terrain shapeChanged];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        //Get touch locations in world meters
        CGPoint location      = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        CGPoint previousPoint = [self transformTouchLocationFromTouchView:[touch previousLocationInView:touch.view]];
        
        //Add circle
        [envScene.environment.terrain clipCircle:_brushradius>0 WithRadius:fabs(_brushradius) x:location.x y:location.y];
        
        //Add/subtract the rectangle
        [envScene.environment.terrain bridgeCircles:_brushradius>0 from:previousPoint to:location radiusUsed:fabs(_brushradius)];
    }
    
    [envScene.environment.terrain shapeChanged];
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


@end




