//
//  MaskedSprite.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/11/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "CCSprite.h"

@interface MaskedSprite : CCSprite <NSCoding>

- (void)addCircleAt:   (CGPoint)center radius:(float)radius;
- (void)removeCircleAt:(CGPoint)center radius:(float)radius;

- (void)addPolygon:   (CGPoint *)poly numPoints:(NSUInteger)numberOfPoints;
- (void)removePolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints;

- (BOOL)saveMaskToFile:(NSString *)fileName;
- (id)initWithFile:(NSString *)file size:(CGSize)size;
- (void)clear;

@end
