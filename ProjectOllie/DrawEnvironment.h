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


#define smallradius 10.0f
#define mediumradius 20.0f
#define largeradius 30.0f

@interface DrawEnvironment : CCLayer

@property (assign, nonatomic)gpc_polygon *newpoly;
@property (assign, nonatomic)gpc_polygon *smallcircle;
@property (assign, nonatomic)gpc_polygon *mediumcircle;
@property (assign, nonatomic)gpc_polygon *largecircle;
@property (assign, nonatomic)int numpoints;
@property (assign, nonatomic)CGPoint prevpoint;
@property (assign, nonatomic)gpc_polygon *brush;
@property (assign, nonatomic)float brushradius;

@property (nonatomic, strong)Terrain *terrain;

-(gpc_polygon *)rectangleMakeWithPoint:(CGPoint)pointa andPoint:(CGPoint)pointb withWidth:(float) width;
+(CCScene *) scene;
@end
