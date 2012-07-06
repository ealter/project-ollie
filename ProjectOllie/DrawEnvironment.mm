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

@interface DrawEnvironment () <DrawMenu_delegate>

- (CGPoint)transformTouchLocationFromTouchView:(CGPoint)location;
- (void)drawCircleAt:(CGPoint)location;

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
        self.terrain = [[Terrain alloc]initWithTextureType:kTerrainTexture_pattern1];
        [self addChild:self.terrain];
        self.isTouchEnabled = YES;
        self.brushradius    = smallradius;
        
        DrawMenu *drawnode = (DrawMenu *)[CCBReader nodeGraphFromFile:@"DrawMenu.ccbi"];
        drawnode.delegate = self;
        [self addChild:drawnode];
        
	}
	return self;
}

- (CGPoint)transformTouchLocationFromTouchView:(CGPoint)location
{
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    float brushradius = fabs(self.brushradius);
    if (location.x -brushradius<self.contentSize.width/20) {
        location.x=self.contentSize.width/20+brushradius;
    }
    if (location.x +brushradius>self.contentSize.width*0.95) {
        location.x=self.contentSize.width*0.95-brushradius;
    }
    if (location.y -brushradius<self.contentSize.height/20) {
        location.y=self.contentSize.height/20+brushradius;
    }
    if (location.y+brushradius>self.contentSize.height*0.9) {
        location.y=self.contentSize.height*0.9-brushradius;
    }
    return location;
}

- (void)drawCircleAt:(CGPoint)location
{
    if (self.brushradius > 0) {
        [self.terrain addCircleWithRadius:self.brushradius x:location.x y:location.y];
    } else {
        [self.terrain removeCircleWithRadius:-self.brushradius x:location.x y:location.y];
    }
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint location = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        [self drawCircleAt:location];
    }
    
    [self.terrain shapeChanged];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint location      = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        CGPoint previousPoint = [self transformTouchLocationFromTouchView:[touch previousLocationInView:touch.view]];
        
        //Add circle
        [self drawCircleAt:location];

        //Compute rectangle
        //Make unit vector between the two points
        CGPoint vector = ccpSub(location, previousPoint);
        if (fabs(vector.x) <FLT_EPSILON && fabs(vector.y) <FLT_EPSILON) return;
        CGPoint unitvector = ccpNormalize(vector);
        
        //Rotate vector left by 90 degrees, multiply by desired width
        unitvector = ccpPerp(unitvector);
        unitvector = ccpMult(unitvector, self.terrain fabs(self.brushradius));
        
        CGPoint points[] = {ccpAdd(location,      unitvector),
                            ccpAdd(previousPoint, unitvector),
                            ccpSub(previousPoint, unitvector),
                            ccpSub(location,      unitvector)};
        
        //Add/subtract the rectangle
        if (self.brushradius > 0) {
            [self.terrain addQuadWithPoints:points];
        } else {
            [self.terrain removeQuadWithPoints:points];
            //[terrain removeCircleWithRadius:-brushradius x:location.x y:location.y];
        }
         
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
