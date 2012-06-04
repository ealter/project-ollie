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
@synthesize gpc_polys, newpoly, radius;

-(id) init
{
	if(self=[super init]) {
        radius = 3;
	}
	return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    newpoly = [[polywrapper alloc] init];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    float anglecount = 0;
    //Malloc new gpc_polygon and a new contour
    newpoly.gpc_polygon = new gpc_polygon;
    newpoly.gpc_polygon->num_contours += 1;
    newpoly.gpc_polygon->contour = new gpc_vertex_list;
    //create the contour, a circle with predefined radius
    for (int i =0; i<20; i++) {
        ccVertex2F *newvertex;
        newvertex->x = location.x+(sinf(anglecount)*radius);
        newvertex->y = location.y+(cosf(anglecount)*radius);
        newpoly.gpc_polygon->contour->num_vertices += 1;
        newpoly.gpc_polygon->contour->vertex = newvertex;
        anglecount += 18;
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    float anglecount = 0;
    
    //Make new contour to hold the new circle
    newpoly.gpc_polygon->num_contours += 1;
    newpoly.gpc_polygon->contour = new gpc_vertex_list;
    for (int i =0; i<20; i++) {
        ccVertex2F *newvertex;
        newvertex->x = location.x+(sinf(anglecount)*radius);
        newvertex->y = location.y+(cosf(anglecount)*radius);
        newpoly.gpc_polygon->contour->num_vertices += 1;
        newpoly.gpc_polygon->contour->vertex = newvertex;
        anglecount += 18;
    }
    
    //Make a rectangle to connect the two circles
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    float anglecount = 0;
    
    //Make new contour to hold the new circle
    newpoly.gpc_polygon->num_contours += 1;
    newpoly.gpc_polygon->contour = new gpc_vertex_list;
    for (int i =0; i<20; i++) {
        ccVertex2F *newvertex;
        newvertex->x = location.x+(sinf(anglecount)*radius);
        newvertex->y = location.y+(cosf(anglecount)*radius);
        newpoly.gpc_polygon->contour->num_vertices += 1;
        newpoly.gpc_polygon->contour->vertex = newvertex;
        anglecount += 18;
    }
    
    //Add newpoly to the array of gpc_polys
    [gpc_polys addObject:newpoly];
}

@end
