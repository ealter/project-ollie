//
//  GWPerspectiveLayer.h
//  ProjectOllie
//  
//  This is an extension of the cocos layer node that transforms
//  to screen coordinates according to a perspective camera, GWCamera. 
//  By transforming only at drawing time, we can use the layer's 
//  position and scaling without fucking everything up.
//
//  Created by a master of the lions, Steve Gregory, on 8/3/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "CCLayer.h"

@class GWCamera;

@interface GWPerspectiveLayer : CCLayer

@property GWCamera *gwCamera;
@property float z;

- (id) initWithCamera:(GWCamera*)gwCamera z:(float)z;

@end
