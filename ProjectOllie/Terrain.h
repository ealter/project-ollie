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
    NSMutableArray *landBlocks;
}

@property (nonatomic,strong) CCTexture2D *texture;

- (id) initWithTexture:(CCTexture2D*)t;

//Building land
- (void) addPolygon:(gpc_polygon*)p;

//Removing land
- (void) removeCircleWithRadius:(float)r x:(float)x y:(float)y;
- (void) removePolygon:(gpc_polygon*)p;

+ (Terrain*) generateRandomOneIsland;
+ (Terrain*) generateRandomTwoIsland;
+ (Terrain*) generateRandomBlobs;
+ (Terrain*) generateRandomCavern;

@end

/* LandBlock helper class */

// A physically independant piece of land with its own body and shape
@interface LandBlock : NSObject
@property(nonatomic)           gpc_polygon  *poly;       //Adding/subtracting (real model)
@property(nonatomic, readonly) b2Body       *body;       //Physics (derived)
@property(nonatomic, readonly) gpc_tristrip *triStrip;   //Drawing (derived)
- (id) initWithPoly:(gpc_polygon*)p;    //Creates a new land block
- (void) shapeChanged;                  //Polygon was changed, so the derived properies must be updated
@end


