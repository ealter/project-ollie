//
//  GWWater.h
//  ProjectOllie
//
//  Created by Lion User on 7/5/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWPerspectiveLayer.h"

@class GWCamera;

@interface GWWater : GWPerspectiveLayer

- (id) initWithCamera:(GWCamera*)camera z:(float)z;

- (void) setColor:(ccColor4F)color;

@end
