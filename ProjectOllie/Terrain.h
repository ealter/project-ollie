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

/*   Terrain class  */
// Manages pieces of land: adds, removes, draws, generates
@interface Terrain : CCNode {
    gpc_polygon 	land;       //Model of all the land as contours
    b2World*        world;      //Physical world this land is in
    gpc_tristrip    triStrips;  //Triangle strips used for drawing
    NSMutableArray  *b2Bodies;  //Bodies of chain shapes currently in the world
}

@property (nonatomic,strong) CCTexture2D *texture;

- (id) initWithTexture:(CCTexture2D*)t;

//Building land
- (void) addPolygon:(gpc_polygon*)p;

//Removing land
- (void) removeCircleWithRadius:(float)r x:(float)x y:(float)y;
- (void) removePolygon:(gpc_polygon*)p;

//Call whenever shape is changed to rebuild the derived physical bodies and drawing 
- (void) shapeChanged;

+ (Terrain*) generateRandomOneIsland;
+ (Terrain*) generateRandomTwoIsland;
+ (Terrain*) generateRandomBlobs;
+ (Terrain*) generateRandomCavern;

@end



