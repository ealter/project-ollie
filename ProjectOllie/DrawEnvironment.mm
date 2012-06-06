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
@synthesize newpoly, smallradius, smallcircle, numpoints, prevpoint;
@synthesize mediumcircle, mediumradius, largecircle, largeradius, terrain;

-(id) init
{
	if(self=[super init]) {
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"pattern1.png"];
        terrain = [[Terrain alloc]initWithTexture:texture];
        smallradius = 3;
        mediumradius = 5;
        largeradius = 8;
        numpoints = 20;
        
        //Code to make small circle
        smallcircle = new gpc_polygon;
        smallcircle->hole=0;
        smallcircle->contour = new vertex_list;
        smallcircle->contour->vertex = new ccVertex2F[numpoints];
        smallcircle->num_contours +=1;
        float anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount*M_PI/180)*smallradius);
            newvertex.y = (cosf(anglecount*M_PI/180)*smallradius);
            smallcircle->contour->num_vertices += 1;
            smallcircle->contour->vertex[i] = newvertex;
            anglecount += (360/numpoints);
        }
        
        //Medium circle
        mediumcircle = new gpc_polygon;
        mediumcircle->hole=0;
        mediumcircle->contour = new vertex_list;
        mediumcircle->contour->vertex = new ccVertex2F[numpoints];
        mediumcircle->num_contours +=1;
        anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount*M_PI/180)*mediumradius);
            newvertex.y = (cosf(anglecount*M_PI/180)*mediumradius);
            mediumcircle->contour->num_vertices += 1;
            mediumcircle->contour->vertex[i] = newvertex;
            anglecount += (360/numpoints);
        }
        
        //Large circle
        largecircle = new gpc_polygon;
        largecircle->hole=0;
        largecircle->contour = new vertex_list;
        largecircle->contour->vertex = new ccVertex2F[numpoints];
        largecircle->num_contours +=1;
        anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount*M_PI/180)*largeradius);
            newvertex.y = (cosf(anglecount*M_PI/180)*largeradius);
            largecircle->contour->num_vertices += 1;
            largecircle->contour->vertex[i] = newvertex;
            anglecount += (360/numpoints);
        }
        
	}
	return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    prevpoint = location;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    //makes sure the circles are far enough away to merit new circle
    if (sqrt((location.x-prevpoint.x)*(location.x-prevpoint.x)+(location.y-prevpoint.y)*(location.y-prevpoint.y))>3)
    {
        
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(gpc_polygon)rectangleMakeWithPoint:(CGPoint)pointa andPoint:(CGPoint)pointb withWidth:(int)width
{
    gpc_polygon *rectangle = new gpc_polygon;
    rectangle->hole=0;
    
    //Make unit vector between the two points
    CGPoint unitvector;
    unitvector.x = (pointa.x - pointb.x);
    unitvector.y = (pointa.y - pointb.y);
    unitvector.x = unitvector.x/sqrt((unitvector.x*unitvector.x) + (unitvector.y*unitvector.y));
    unitvector.y = unitvector.y/sqrt((unitvector.x*unitvector.x) + (unitvector.y*unitvector.y));
    
    //Rotate vector by 90 degrees, multiply by desired width
    float holdy = unitvector.y;
    unitvector.y=unitvector.x;
    unitvector.x=-holdy;
    
    unitvector.y=unitvector.y*width;
    unitvector.x=unitvector.x*width;
    
    //Find the points, add them to the gpc_polygon
    ccVertex2F corner1;
    ccVertex2F corner2;
    ccVertex2F corner3;
    ccVertex2F corner4;
    corner1.x = pointa.x+unitvector.x;
    corner1.y = pointa.y+unitvector.y;
    corner2.x = pointa.x-unitvector.x;
    corner2.y = pointa.y-unitvector.y;
    corner3.x = pointa.x+unitvector.x;
    corner3.y = pointa.y+unitvector.y;
    corner4.x = pointa.x-unitvector.x;
    corner4.y = pointa.y-unitvector.y;
    
    rectangle->contour = new vertex_list;
    rectangle->contour->num_vertices=4;
    rectangle->contour->vertex = new ccVertex2F[4];
    rectangle->contour->vertex[0]=corner1;
    rectangle->contour->vertex[1]=corner2;
    rectangle->contour->vertex[2]=corner3;
    rectangle->contour->vertex[4]=corner4;
    
    return *rectangle;
}

@end
