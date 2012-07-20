//
//  Terrain.h
//  ProjectOllie
//
//  Created by Steve Gregory on 6/4/12.
//  Copyright 2012 hi ku. All rights reserved.
//

#import "CCNode.h"
#include <vector>

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
// Manages pieces of land: adds, removes, draws, generates
@interface Terrain : CCNode <NSCoding> {
    std::vector<b2Body*> b2Bodies;   //Bodies of chain shapes currently in the world
    b2World             *world;      //Physical world this land is in
    ShapeField          *shapeField_;
}

@property (nonatomic, strong) CCTexture2D *texture;

- (id) initWithTextureType:(TerrainTexture)textureType;

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
