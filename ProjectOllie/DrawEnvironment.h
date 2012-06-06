//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 hi ku inc. All rights reserved.
//

#import "CCScene.h"
#import "gpc.h"
#import "Terrain.h"

@interface DrawEnvironment : CCScene

@property gpc_polygon *newpoly;
@property gpc_polygon *smallcircle;
@property gpc_polygon *mediumcircle;
@property gpc_polygon *largecircle;
@property float smallradius;
@property float largeradius;
@property float mediumradius;
@property int numpoints;
@property CGPoint prevpoint;

@property (nonatomic, strong)Terrain *terrain;

-(gpc_polygon)rectangleMakeWithPoint:(CGPoint)pointa andPoint:(CGPoint)pointb withWidth:(int) width;
@end
