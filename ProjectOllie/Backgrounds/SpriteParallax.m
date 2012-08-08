//
//  SpriteParallax.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/13/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "SpriteParallax.h"
#import "GameConstants.h"
#import "GWCamera.h"

@implementation SpriteParallax

-(id)initWithFile:(NSString *)filename camera:(GWCamera*)camera
{
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
    if((self = [super init]))// rect:CGRectMake(MIN_VIEWABLE_X, MIN_VIEWABLE_Y, MAX_WIDTH_PX, MAX_HEIGHT_PX)]))
    {
        super.camera = camera;
        CCSprite *bkg = [[CCSprite alloc] initWithFile:filename];
        [self addChild:bkg];
     //   [self setTextureCoords:CGRectMake(0, 0, texture_.pixelsWide, texture_.pixelsHigh)];
     //   [self setTextureRect:CGRectMake(0, 0, texture_.pixelsWide*2, texture_.pixelsHigh*2)
     //                rotated:NO untrimmedSize:CGSizeMake(600, 400)];
    }
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    return self;
}

@end
