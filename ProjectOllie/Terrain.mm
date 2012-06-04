//
//  Terrain.m
//  ProjectOllie
//
//  Created by Lion User on 6/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Terrain.h"


@implementation Terrain

@synthesize texture = texture_;

//Building land
- (void) addPolygon:(gpc_polygon)p
{
    
}

//Removing land
- (void) subtractCircleWithRadius:(float)r x:(float)x y:(float)y
{
    
}

- (void) removePolygon:(gpc_polygon)p
{
    
}

- (void) draw
{
    CC_NODE_DRAW_SETUP();
    
    //Draw each of the land elements
    for (landBlock* L in landBlocks) 
        for (int i = 0; i < L.triStrip.num_strips; i++)
        {
            ccDrawTexturedTriStrip(L.triStrip.strip[i].vertex, 
                                   L.triStrip.texCoords[i].vertex, 
                                   (int)L.triStrip.strip[i].num_vertices, 
                                   self.texture);
        }
}

/* Random Land Generators */

+ (Terrain*) generateRandomOneIsland
{
    
}

+ (Terrain*) generateRandomTwoIsland
{
    
}

+ (Terrain*) generateRandomBlobs
{
    
}

+ (Terrain*) generateRandomCavern
{
    
}

@end
