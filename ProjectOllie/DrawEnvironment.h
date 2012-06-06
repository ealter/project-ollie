//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "CCScene.h"
#import "gpc.h"
#import "Terrain.h"


#define smallradius 30.0f
#define mediumradius 50.0f
#define largeradius 70.0f

@interface DrawEnvironment : CCLayer

@property gpc_polygon *newpoly;
@property gpc_polygon *smallcircle;
@property gpc_polygon *mediumcircle;
@property gpc_polygon *largecircle;
@property int numpoints;
@property CGPoint prevpoint;
@property gpc_polygon *brush;
@property float brushradius;

@property (nonatomic, strong)Terrain *terrain;

-(gpc_polygon *)rectangleMakeWithPoint:(CGPoint)pointa andPoint:(CGPoint)pointb withWidth:(int) width;
+(CCScene *) scene;
@end
