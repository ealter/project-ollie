//
//  Terrain.h
//  ProjectOllie
//
//  Created by Steve Gregory on 6/4/12.
//  Copyright 2012 hi ku. All rights reserved.
//

#include <stdlib.h>
#include <vector>
#import "CCNode.h"

class ShapeField;
class b2World;
class b2Body;	
@class CCTexture2D;

//An enum for the different possible images to use with the texture.
typedef enum TerrainTexture {
    kTerrainTexture_lava = 0,
    kTerrainTexture_rocks,
    kTerrainTexture_gravel,
    kTerrainTexture_vines,
    kTerrainTexture_ice,
    kTerrainTexture_numTextures //Do not use this!
} TerrainTexture;

/*   Terrain class  */
// Manages land: adds, removes, draws, generates
@interface Terrain : CCNode <NSCoding> {
    b2World             *world;      //Physical world this land is in
    ShapeField          *shapeField_;
}

- (id) init;

- (id) initWithTextureType:(TerrainTexture)textureType;

- (void) setStrokeColor:(ccColor4F)color;

- (void) setTexture:(CCTexture2D *)texture;

//Changing land
- (void) clipCircle:(bool)add WithRadius:(float)radius x:(float)x y:(float)y;

//Only call this after two circles have been clipped
- (void) bridgeCircles:(bool)add from:(CGPoint)p1 to:(CGPoint) p2 radiusUsed:(float)r;

//Call whenever shape is changed to rebuild the stroke raster
- (void) shapeChanged;

//Reset to a blank terrain
- (void) clear;

- (void) addToWorld:(b2World*)bworld;

+ (Terrain*) generateRandomOneIsland;
+ (Terrain*) generateRandomTwoIsland;
+ (Terrain*) generateRandomBlobs;
+ (Terrain*) generateRandomCavern;

@end
