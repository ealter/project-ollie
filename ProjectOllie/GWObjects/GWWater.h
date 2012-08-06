//
//  GWWater.h
//  ProjectOllie
//
//  Created by Lion User on 7/5/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"
#import "GWCamera.h"
#import "GWPerspectiveLayer.h"

@interface GWWater : GWPerspectiveLayer

- (id) initWithCamera:(GWCamera*)camera z:(float)z;

@end
