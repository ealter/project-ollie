//
//  DrawEnvironment.m
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
        smallcircle->contour = new vertex_list;
        smallcircle->contour->vertex = new ccVertex2F[numpoints];
        smallcircle->num_contours +=1;
        float anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount)*smallradius);
            newvertex.y = (cosf(anglecount)*smallradius);
            smallcircle->contour->num_vertices += 1;
            smallcircle->contour->vertex[i] = newvertex;
            anglecount += (360/numpoints);
        }
        
        //Medium circle
        mediumcircle->contour = new vertex_list;
        mediumcircle->contour->vertex = new ccVertex2F[numpoints];
        mediumcircle->num_contours +=1;
        anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount)*mediumradius);
            newvertex.y = (cosf(anglecount)*mediumradius);
            mediumcircle->contour->num_vertices += 1;
            mediumcircle->contour->vertex[i] = newvertex;
            anglecount += (360/numpoints);
        }
        
        //Large circle
        largecircle->contour = new vertex_list;
        largecircle->contour->vertex = new ccVertex2F[numpoints];
        largecircle->num_contours +=1;
        anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount)*largeradius);
            newvertex.y = (cosf(anglecount)*largeradius);
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

@end
