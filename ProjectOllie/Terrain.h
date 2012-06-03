//
//  Terrain.h
//  ProjectOllie
//
//  Created by Lion User on 6/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "gpc.h"
#import "Box2D.h"

struct landBlock
{
    gpc_polygon poly;           //Adding/subtracting (real model)
    b2Body      *body;          //Physics (derived)
    ccVertex2F  *triangleVerts; //Drawing (derived)
    NSArray     *texCoords;     //Drawing (derived)
};

@interface Terrain : CCNode {
    NSMutableArray *landBlocks;
    CCTexture2D *texture;           
}

//Building land
- (void) addPolygon:(gpc_polygon)p;

//Removing land
- (void) removeCircleWithRadius:(float)r x:(float)x y:(float)y;
- (void) removePolygon:(gpc_polygon)p;

+ (id) generateRandomIsland;
+ (id) generateRandomTwoIsland;
+ (id) generateRandomBlobs;
+ (id) generateRandomCavern;

@end
