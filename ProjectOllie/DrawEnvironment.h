//
//  DrawEnvironment.h
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCScene.h"
#import "gpc.h"
#import "polywrapper.h"
@interface DrawEnvironment : CCScene

@property (nonatomic, retain) NSMutableArray *gpc_polys;
@property (nonatomic, retain) polywrapper *newpoly;

@end
