//
//  MaskedSprite.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/11/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "CCSprite.h"
#import "CCRenderTexture.h"

@interface MaskedSprite : CCSprite

- (void)drawCircleAt:(CGPoint) center withRadius:(float)radius Additive:(bool)add;
- (void)drawPolygon:(const CGPoint *)poly numPoints:(NSUInteger)numberOfPoints;
- (void)subtractPolygon:(const CGPoint *)poly numPoints:(NSUInteger)numberOfPoints;
- (BOOL)saveMaskToFile:(NSString *)fileName;
- (id)initWithFile:(NSString *)file size:(CGSize)size;

@end
