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
#import "ActionLayer.h"
#import "cocos2d.h"
#import "CCDirector.h"
#import "GameConstants.h"

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
    SandboxScene *scene = [SandboxScene node];
    
    [self removeChild:self.environment cleanup:YES];
    [scene.actionLayer setTerrain:self.environment.terrain];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccBLACK]];
}

@end


@implementation DrawTouchLayer
{
    EnvironmentScene* envScene;
}

@synthesize brushradius = _brushradius;

- (id) initWithEnvironmentScene:(EnvironmentScene*)des
{
    if (self = [super init])
    {
        envScene = des;
        _brushradius = 30;
    }
    return self;
}

- (CGPoint)transformTouchLocationFromTouchView:(CGPoint)location
{
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    float minToEdge = fabs(self.brushradius);
    if (self.brushradius < 0) minToEdge -= 1;
    if (location.x -minToEdge<WORLD_WIDTH_PX/20) {
        location.x=WORLD_WIDTH_PX/20+minToEdge;
    }
    if (location.x +minToEdge>WORLD_WIDTH_PX*0.95) {
        location.x=WORLD_WIDTH_PX*0.95-minToEdge;
    }
    if (location.y -minToEdge<WORLD_HEIGHT_PX/20) {
        location.y=WORLD_HEIGHT_PX/20+minToEdge;
    }
    if (location.y+minToEdge>WORLD_WIDTH_PX*0.95) {
        location.y=WORLD_WIDTH_PX*0.95-minToEdge;
    }
    return location;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint location = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        [envScene.environment.terrain clipCircle:_brushradius>0 WithRadius:fabs(_brushradius) x:location.x y:location.y];
    }
    
    [envScene.environment.terrain shapeChanged];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
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




