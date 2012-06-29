//
//  DrawEnvironment.m
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "DrawEnvironment.h"
#import "AppDelegate.h"
#import "PhysicsSprite.h"
#import "CCBReader.h"
#import "DrawMenu.h"
#import "Terrain.h"
#import "SandboxScene.h"

@interface DrawEnvironment () <DrawMenu_delegate>

@end

@implementation DrawEnvironment
@synthesize numpoints, prevpoint, brushradius;
@synthesize terrain;

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
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"pattern1.png"];
        terrain = [[Terrain alloc]initWithTexture:texture];
        [self addChild:terrain];
        self.isTouchEnabled = YES;
                
        brushradius = smallradius;
        
        /*
        /Load the menu for the drawing environment
        */
        DrawMenu *drawnode = (DrawMenu *)[CCBReader nodeGraphFromFile:@"DrawMenu.ccbi"];
        drawnode.delegate = self;
        [self addChild:drawnode];
	}
	return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    
    //Apply bounds
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
    
    //Add or subtract a circle
    if (brushradius > 0)
    {
        [terrain addCircleWithRadius:brushradius x:location.x y:location.y];
    }
    else 
    {
        [terrain removeCircleWithRadius:-brushradius x:location.x y:location.y];
    }
    
    prevpoint = location;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    
    //Apply bounds
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
    
    //Compute rectangle
    //Make unit vector between the two points
    CGPoint unitvector;
    unitvector.x = (location.x - prevpoint.x);
    unitvector.y = (location.y - prevpoint.y);
    float len = sqrt((unitvector.x*unitvector.x) + (unitvector.y*unitvector.y));
    if (len == 0) return;
    unitvector.x = unitvector.x/len;
    unitvector.y = unitvector.y/len;
    
    //Rotate vector by 90 degrees, multiply by desired width
    float holdy = unitvector.y;
    unitvector.y=unitvector.x;
    unitvector.x=-holdy;
    
    unitvector.y=unitvector.y*fabs(brushradius);
    unitvector.x=unitvector.x*fabs(brushradius);
    
    //Find the points, add them to the gpc_polygon
    CGPoint points[] = {ccp(location.x+unitvector.x, location.y+unitvector.y),
                        ccp(prevpoint.x+unitvector.x, prevpoint.y+unitvector.y),
                        ccp(prevpoint.x-unitvector.x, prevpoint.y-unitvector.y),
                        ccp(location.x-unitvector.x, location.y-unitvector.y)};
    
    //Add/subtract the rectangle
    if (brushradius > 0)
    {
        [terrain addQuadWithPoints:points];
        [terrain addCircleWithRadius:brushradius x:location.x y:location.y];
    }
    else 
    {
        [terrain removeQuadWithPoints:points];
        //[terrain removeCircleWithRadius:-brushradius x:location.x y:location.y];
    }
    
    prevpoint = location;
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
