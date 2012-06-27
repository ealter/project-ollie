//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "CCLayer.h"

#define smallradius 10.0f
#define mediumradius 20.0f
#define largeradius 30.0f

@class Terrain;
@class CCScene;

@interface DrawEnvironment : CCLayer

@property int numpoints;
@property float brushradius;

@property (nonatomic, strong) Terrain *terrain;

+(CCScene *) scene;
@end
