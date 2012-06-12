//
//  MaskedSprite.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/11/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "CCSprite.h"
#import "CCRenderTexture.h"

@interface MaskedSprite : CCSprite {
    CCRenderTexture * _maskTexture;
    GLuint _textureLocation;
    GLuint _maskLocation;
}

- (void)drawPolygon:(const CGPoint *)poly numPoints:(NSUInteger)numberOfPoints;
- (BOOL)saveMaskToFile:(NSString *)fileName;

@end
