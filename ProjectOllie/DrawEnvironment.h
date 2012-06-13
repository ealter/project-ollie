//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "CCScene.h"
#import "Terrain.h"


#define smallradius 30.0f
#define mediumradius 50.0f
#define largeradius 70.0f

@interface DrawEnvironment : CCLayer

@property int numpoints;
@property CGPoint prevpoint;
@property float brushradius;

@property (nonatomic, strong)Terrain *terrain;

+(CCScene *) scene;
@end
