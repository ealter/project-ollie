//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Tucker Stone on 6/2/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "CCLayer.h"


@class Terrain;
@class CCScene;

@interface DrawEnvironment : CCLayer

@property (nonatomic) int numpoints;
@property (nonatomic) float brushradius;

@property (nonatomic, strong) Terrain *terrain;

+ (CCScene *)scene;

@end
