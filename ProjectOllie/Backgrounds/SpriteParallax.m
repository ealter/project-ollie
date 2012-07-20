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

-(id)initWithFile:(NSString *)filename{
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
    if((self = [super initWithFile:filename]))
    {
        
    }
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    return self;
}

- (bool)isBounded
{
    return false;
}

- (float)getParallaxRatio
{
    return self.parallaxRatio;
}

@end
