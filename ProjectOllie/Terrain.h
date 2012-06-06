//
//  Terrain.h
//  ProjectOllie
//
//  Created by Steve Gregory on 6/4/12.
//  Copyright 2012 hi ku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "gpc.h"
#import "Box2D.h"
#include <vector>

/*   Terrain class  */
// Manages pieces of land: adds, removes, draws, generates
@interface Terrain : CCNode {
    gpc_polygon          land;       //Model of all the land as contours
    gpc_tristrip         triStrips;  //Triangle strips used for drawing
    std::vector<b2Body*> b2Bodies;   //Bodies of chain shapes currently in the world
    b2World             *world;      //Physical world this land is in
}

@property (nonatomic,strong) CCTexture2D *texture;

- (id) initWithTexture:(CCTexture2D*)t;

//Building land
- (void) addPolygon:(gpc_polygon*)p;

//Removing land
- (void) removePolygon:(gpc_polygon*)p;

//Call whenever shape is changed to rebuild the derived physical bodies and drawing 
- (void) shapeChanged;

+ (Terrain*) generateRandomOneIsland;
+ (Terrain*) generateRandomTwoIsland;
+ (Terrain*) generateRandomBlobs;
+ (Terrain*) generateRandomCavern;

@end



