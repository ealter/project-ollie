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
@synthesize newpoly, smallcircle, numpoints, prevpoint, brush, brushradius;
@synthesize mediumcircle, largecircle, terrain;

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
        
        numpoints = 20;
        
        //Code to make small circle
        smallcircle = new gpc_polygon;
        smallcircle->hole=new int(0);
        smallcircle->contour = new vertex_list;
        smallcircle->contour[0].vertex = new ccVertex2F[numpoints];
        smallcircle->contour[0].num_vertices = 0;
        smallcircle->num_contours =1;
        float anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount*M_PI/180)*smallradius);
            newvertex.y = (cosf(anglecount*M_PI/180)*smallradius);
            smallcircle->contour[0].num_vertices += 1;
            smallcircle->contour[0].vertex[i] = newvertex;
            anglecount += (360.0f/numpoints);
        }
        
        //Medium circle
        mediumcircle = new gpc_polygon;
        mediumcircle->hole=new int(0);
        mediumcircle->contour = new vertex_list;
        mediumcircle->contour[0].vertex = new ccVertex2F[numpoints];
        mediumcircle->contour[0].num_vertices = 0;
        mediumcircle->num_contours =1;
        anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount*M_PI/180)*mediumradius);
            newvertex.y = (cosf(anglecount*M_PI/180)*mediumradius);
            mediumcircle->contour[0].num_vertices += 1;
            mediumcircle->contour[0].vertex[i] = newvertex;
            anglecount += (360.0f/numpoints);
        }
        
        //Large circle
        largecircle = new gpc_polygon;
        largecircle->hole=new int(0);
        largecircle->contour = new vertex_list;
        largecircle->num_contours =1;
        largecircle->contour[0].vertex = new ccVertex2F[numpoints];
        largecircle->contour[0].num_vertices = 0;
        anglecount = 0;
        for (int i =0; i<numpoints; i++) {
            ccVertex2F newvertex;
            newvertex.x = (sinf(anglecount*M_PI/180)*largeradius);
            newvertex.y = (cosf(anglecount*M_PI/180)*largeradius);
            largecircle->contour[0].num_vertices += 1;
            largecircle->contour[0].vertex[i] = newvertex;
            anglecount += (360.0f/numpoints);
        }
        brush = smallcircle;
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
    
    gpc_polygon *newcircle = gpc_offset_clone(brush, location.x, location.y);
    [terrain addPolygon:newcircle];
    //gpc_free_polygon(newcircle);
    delete newcircle;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];
    
    //makes sure the circles are far enough away to merit new circle
    if (sqrt((location.x-prevpoint.x)*(location.x-prevpoint.x)+(location.y-prevpoint.y)*(location.y-prevpoint.y))>10)
    {
        gpc_polygon *newcircle = gpc_offset_clone(brush, location.x, location.y);
        [terrain addPolygon:newcircle];
        gpc_free_polygon(newcircle);
        delete newcircle;
        
        gpc_polygon *newrectangle = [self rectangleMakeWithPoint:prevpoint andPoint:location withWidth:brushradius];
        [terrain addPolygon:newrectangle];
        gpc_free_polygon(newrectangle);
        delete newrectangle;
        
        prevpoint = location;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [self convertToNodeSpace:location];

    gpc_polygon *newcircle = gpc_offset_clone(brush, location.x, location.y);
    [terrain addPolygon:newcircle];
    gpc_free_polygon(newcircle);
    delete newcircle;
    
    gpc_polygon *newrectangle = [self rectangleMakeWithPoint:prevpoint andPoint:location withWidth:brushradius];
    [terrain addPolygon:newrectangle];
    gpc_free_polygon(newrectangle);
    delete newrectangle;
}


//MAKE SURE YOU FREE THE RECTANGLE AFTER YOU MAKE IT
-(gpc_polygon *)rectangleMakeWithPoint:(CGPoint)pointa andPoint:(CGPoint)pointb withWidth:(float)width
{
    gpc_polygon *rectangle = new gpc_polygon;
    rectangle->hole=new int(0);
    rectangle->num_contours = 1;
    
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
    ccVertex2F corner1;
    ccVertex2F corner2;
    ccVertex2F corner3;
    ccVertex2F corner4;
    corner1.x = pointa.x+unitvector.x;
    corner1.y = pointa.y+unitvector.y;
    corner2.x = pointa.x-unitvector.x;
    corner2.y = pointa.y-unitvector.y;
    corner3.x = pointb.x-unitvector.x;
    corner3.y = pointb.y-unitvector.y;
    corner4.x = pointb.x+unitvector.x;
    corner4.y = pointb.y+unitvector.y;
    
    rectangle->contour = new vertex_list;
    rectangle->contour->num_vertices=4;
    rectangle->contour->vertex = new ccVertex2F[4];
    rectangle->contour->vertex[0]=corner1;
    rectangle->contour->vertex[1]=corner2;
    rectangle->contour->vertex[2]=corner3;
    rectangle->contour->vertex[3]=corner4;
    
    return rectangle;
}

@end
