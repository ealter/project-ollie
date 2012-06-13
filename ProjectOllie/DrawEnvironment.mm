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
        
	}
	return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    
    prevpoint = location;
    
    [terrain addCircleWithRadius:brushradius x:location.x y:location.y];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    
    //makes sure the circles are far enough away to merit new circle
    
    if (ccpDistanceSQ(location, prevpoint)>1)
    {
        [terrain addCircleWithRadius:brushradius x:location.x y:location.y];
        
        prevpoint = location;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{/*
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];

    gpc_polygon *newcircle = gpc_offset_clone(brush, location.x, location.y);
    [terrain addPolygon:newcircle];
    gpc_free_polygon(newcircle);
    delete newcircle;
    
    gpc_polygon newrectangle = [self rectangleMakeWithPoint:prevpoint andPoint:location withWidth:brushradius];
    [terrain addPolygon:&newrectangle];
    gpc_free_polygon(&newrectangle);*/
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
