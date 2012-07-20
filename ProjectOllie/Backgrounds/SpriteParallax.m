//
//  SpriteParallax.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/13/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "SpriteParallax.h"

@implementation SpriteParallax
@synthesize parallaxRatio = _parallaxRatio;

- (bool)isBounded
{
    return false;
}

- (float)getParallaxRatio
{
    return self.parallaxRatio;
}

@end
