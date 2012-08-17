//
//  SpriteParallax.h
//  ProjectOllie
//
//  Created by Eliot Alter on 7/13/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "CCSprite.h"
#import "GWPerspectiveLayer.h"

@class GWCamera;

@interface SpriteParallax : GWPerspectiveLayer

-(id)initWithFile:(NSString *)filename camera:(GWCamera*)gwCamera;

@end
