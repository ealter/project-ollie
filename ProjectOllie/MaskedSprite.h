//
//  MaskedSprite.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/11/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "CCSprite.h"

//This class provides a way to mask over a sprite. The sprite starts off as completely transparent.
//As you add shapes to it, those parts of the sprite become opaque again. Removing shapes makes the parts
//transparent again.

@interface MaskedSprite : CCSprite

- (void)addCircleAt:   (CGPoint)center radius:(float)radius;
- (void)removeCircleAt:(CGPoint)center radius:(float)radius;

- (void)addPolygon:   (CGPoint *)poly numPoints:(NSUInteger)numberOfPoints;
- (void)removePolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints;

- (void)addPoints:    (NSArray *)points; //An array of CGPoints (encapsulated in NSValues)
- (void)removePoints: (NSArray *)points;

//Saves the mask to a file is possible. Returns true on success
- (BOOL)saveMaskToFile:(NSString *)fileName;
//Designated initializer
- (id)initWithFile:(NSString *)file size:(CGSize)size;
//Sets the entire shape to transparent again.
- (void)clear;

@end
