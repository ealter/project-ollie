//
//  Terrain.h
//  ProjectOllie
//
//  Created by Steve Gregory on 6/4/12.
//  Copyright 2012 hi ku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#include <vector>
#import "ShapeField.h"

/*   Terrain class  */
// Manages pieces of land: adds, removes, draws, generates
@interface Terrain : CCNode {
    std::vector<b2Body*> b2Bodies;   //Bodies of chain shapes currently in the world
    b2World             *world;      //Physical world this land is in
    ShapeField          *shapeField;
}

@property (nonatomic,strong) CCTexture2D *texture;

- (id) initWithTexture:(CCTexture2D*)t;

//Building land
- (void) addCircleWithRadius:(float)r x:(float)x y:(float)y;

//Removing land
- (void) removeCircleWithRadius:(float)r x:(float)x y:(float)y;


+ (Terrain*) generateRandomOneIsland;
+ (Terrain*) generateRandomTwoIsland;
+ (Terrain*) generateRandomBlobs;
+ (Terrain*) generateRandomCavern;

@end



