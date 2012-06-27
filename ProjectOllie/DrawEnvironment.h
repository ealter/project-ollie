//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Tucker Stone on 6/2/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "CCScene.h"
#import "cocos2d.h"

#define smallradius 10.0f
#define mediumradius 20.0f
#define largeradius 30.0f

@class Terrain;

@interface DrawEnvironment : CCLayer

@property int numpoints;
@property CGPoint prevpoint;
@property float brushradius;

@property (nonatomic, strong)Terrain *terrain;

+(CCScene *) scene;
@end
