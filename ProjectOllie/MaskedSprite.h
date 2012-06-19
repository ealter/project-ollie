//
//  MaskedSprite.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/11/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "CCSprite.h"

@interface MaskedSprite : CCSprite

- (void)drawCircleAt:(CGPoint) center withRadius:(float)radius Additive:(bool)add;
- (void)drawPolygon:(const CGPoint *)poly numPoints:(NSUInteger)numberOfPoints Additive:(bool)add;
- (void)drawLines:(const CGPoint*)poly numPoints:(NSUInteger)num;
- (BOOL)saveMaskToFile:(NSString *)fileName;
- (id)initWithFile:(NSString *)file size:(CGSize)size;
- (void)clear;

@end
