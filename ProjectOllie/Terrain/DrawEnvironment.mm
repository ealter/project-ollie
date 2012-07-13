//
//  DrawEnvironment.m
//  ProjectOllie
//
//  Created by Tucker Stone on 6/2/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "DrawEnvironment.h"
#import "AppDelegate.h"
#import "PhysicsSprite.h"
#import "CCBReader.h"
#import "DrawMenu.h"
#import "Terrain.h"
#import "SandboxScene.h"
#import "ActionLayer.h"
#import "MaskedSprite.h"

@interface DrawEnvironment () <DrawMenu_delegate>

- (CGPoint)transformTouchLocationFromTouchView:(CGPoint)location;

@end

@implementation DrawEnvironment
@synthesize numpoints   = _numpoints;
@synthesize brushradius = _brushradius;
@synthesize terrain     = _terrain;

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    DrawEnvironment *layer = [DrawEnvironment node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

-(id) init
{
	if(self=[super init]) {
        self.terrain = [[Terrain alloc]initWithTextureType:kTerrainTexture_lava];
        [self addChild:self.terrain];
        self.isTouchEnabled = YES;
        self.brushradius    = smallradius;
        
        DrawMenu *drawnode = (DrawMenu *)[CCBReader nodeGraphFromFile:@"DrawMenu.ccbi"];
        assert([drawnode isKindOfClass:[DrawMenu class]]);
        drawnode.delegate = self;
        [self addChild:drawnode];
        
	}
	return self;
}

- (CGPoint)transformTouchLocationFromTouchView:(CGPoint)location
{
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    float minToEdge = fabs(self.brushradius);
    if (self.brushradius < 0) minToEdge -= 1;
    if (location.x -minToEdge<self.contentSize.width/20) {
        location.x=self.contentSize.width/20+minToEdge;
    }
    if (location.x +minToEdge>self.contentSize.width*0.95) {
        location.x=self.contentSize.width*0.95-minToEdge;
    }
    if (location.y -minToEdge<self.contentSize.height/20) {
        location.y=self.contentSize.height/20+minToEdge;
    }
    if (location.y+minToEdge>self.contentSize.height*0.9) {
        location.y=self.contentSize.height*0.9-minToEdge;
    }
    return location;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint location = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        [self.terrain clipCircle:_brushradius>0 WithRadius:fabs(_brushradius) x:location.x y:location.y];
    }
    
    [self.terrain shapeChanged];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint location      = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        CGPoint previousPoint = [self transformTouchLocationFromTouchView:[touch previousLocationInView:touch.view]];
        
        //Add circle
        [self.terrain clipCircle:_brushradius>0 WithRadius:fabs(_brushradius) x:location.x y:location.y];

        //Add/subtract the rectangle
        [self.terrain bridgeCircles:_brushradius>0 from:previousPoint to:location radiusUsed:fabs(_brushradius)];
    }
    
    [self.terrain shapeChanged];
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)DrawMenu_setBrushRadius:(CGFloat)radius
{
    self.brushradius = radius;
    
}

- (void)DrawMenu_clearDrawing
{
    [self.terrain clear];
}

- (void)DrawMenu_doneDrawing
{
    SandboxScene *scene = [SandboxScene node];
    
    [self removeChild:self.terrain cleanup:YES];
    [scene.actionLayer addChild:self.terrain];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end