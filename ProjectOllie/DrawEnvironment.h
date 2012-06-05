//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCScene.h"
#import "gpc.h"
@interface DrawEnvironment : CCScene

@property gpc_polygon *newpoly;
@property gpc_polygon *smallcircle;
@property gpc_polygon *mediumcircle;
@property gpc_polygon *largecircle;
@property float smallradius;
@property float largeradius;
@property float mediumradius;
@property int numpoints;
@end
