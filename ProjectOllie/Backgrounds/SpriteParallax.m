//
//  SpriteParallax.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/13/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "SpriteParallax.h"
#import "GameConstants.h"

@implementation SpriteParallax
@synthesize parallaxRatio = _parallaxRatio;

-(id)initWithFile:(NSString *)filename{
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
    if((self = [super initWithFile:filename rect:CGRectMake(MIN_VIEWABLE_X, MIN_VIEWABLE_Y, MAX_WIDTH_PX, MAX_HEIGHT_PX)]))
    {
        [self setTextureCoords:CGRectMake(0, 0, texture_.pixelsWide, texture_.pixelsHigh)];
     //   [self setTextureRect:CGRectMake(0, 0, texture_.pixelsWide*2, texture_.pixelsHigh*2)
     //                rotated:NO untrimmedSize:CGSizeMake(600, 400)];
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
