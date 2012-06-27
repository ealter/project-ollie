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
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"pattern1.png"];
        self.terrain = [[Terrain alloc]initWithTexture:texture];
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
    float brushradius = self.brushradius;
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
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint location = [self transformTouchLocationFromTouchView:[touch locationInView:touch.view]];
        [self drawCircleAt:location];
    }
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

/*
//MAKE SURE YOU FREE THE RECTANGLE AFTER YOU MAKE IT
-(gpc_polygon)rectangleMakeWithPoint:(CGPoint)pointa andPoint:(CGPoint)pointb withWidth:(float)width
{
    gpc_polygon rectangle;
    rectangle.hole=new int(0);
    rectangle.num_contours = 1;
    
    //Make unit vector between the two points
    CGPoint unitvector;
    unitvector.x = (pointa.x - pointb.x);
    unitvector.y = (pointa.y - pointb.y);
    float len = sqrt((unitvector.x*unitvector.x) + (unitvector.y*unitvector.y));
    unitvector.x = unitvector.x/len;
    unitvector.y = unitvector.y/len;
    
    //Rotate vector by 90 degrees, multiply by desired width
    float holdy = unitvector.y;
    unitvector.y=unitvector.x;
    unitvector.x=-holdy;
    
    unitvector.y=unitvector.y*width;
    unitvector.x=unitvector.x*width;
    
    //Find the points, add them to the gpc_polygon
    rectangle.contour = new vertex_list;
    rectangle.contour->num_vertices=4;
    rectangle.contour->vertex = new ccVertex2F[4];
    rectangle.contour->vertex[0].x = pointa.x+unitvector.x;
    rectangle.contour->vertex[0].y = pointa.y+unitvector.y;
    rectangle.contour->vertex[1].x = pointa.x-unitvector.x;
    rectangle.contour->vertex[1].y = pointa.y-unitvector.y;
    rectangle.contour->vertex[2].x = pointb.x-unitvector.x;
    rectangle.contour->vertex[2].y = pointb.y-unitvector.y;
    rectangle.contour->vertex[3].x = pointb.x+unitvector.x;
    rectangle.contour->vertex[3].y = pointb.y+unitvector.y;
    
    
    return rectangle;
}
*/
@end
