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

typedef enum TerrainTexture {
    TerrainTexture_pattern1 = 0
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

//Building land
- (void) addCircleWithRadius:(float)radius x:(float)x y:(float)y;
- (void) addQuadWithPoints:(CGPoint[])p;

//Removing land
- (void) removeCircleWithRadius:(float)radius x:(float)x y:(float)y;
- (void) removeQuadWithPoints:(CGPoint[])p;

//Call whenever shape is changed to rebuild the stroke raster
- (void) shapeChanged;

//Reset to a blank terrain
- (void) clear;

+ (Terrain*) generateRandomOneIsland;
+ (Terrain*) generateRandomTwoIsland;
+ (Terrain*) generateRandomBlobs;
+ (Terrain*) generateRandomCavern;

@end



