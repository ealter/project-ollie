//
//  Terrain.m
//  ProjectOllie
//
//  Created by Lion User on 6/4/12.
//  Copyright 2012 hi ku inc. All rights reserved.
//

#import "Terrain.h"


@implementation Terrain

@synthesize texture = texture_;

- (id) initWithTexture:(CCTexture2D*)t
{
    if(self = [super init])
    {
        self->texture_ = t;
        self->b2Bodies = [NSMutableArray array];
        //land and tristrips are structs that are already allocated
    }
    return self;
}

//Building land
- (void) addPolygon:(gpc_polygon*)p
{
    if (p->num_contours == 0) return;
    //Add to the current land
    gpc_polygon* final = (gpc_polygon*) malloc(sizeof(*final));
    gpc_polygon_clip(GPC_UNION, &land, p, final);
    land = *final;
    delete final;
    [self shapeChanged];
}

- (void) removePolygon:(gpc_polygon*)p
{
    if (p->num_contours == 0) return;
    //Add to the current land
    gpc_polygon* final = (gpc_polygon*) malloc(sizeof(*final));
    gpc_polygon_clip(GPC_DIFF, &land, p, final);
    land = *final;
    delete final;
}

- (void) shapeChanged
{
    //If there is an attached world object, update the physical bodies within
    if (world)
    {
        //Remove all the old physical bodies and DESTROY THE FUCK OUT OF THEM
        for (int i = 0; i < b2Bodies.count; i++)
            world->DestroyBody((b2Body*)[b2Bodies objectAtIndex:i]);
        [b2Bodies removeAllObjects];
        
        //Create new bodies
        
    }
    
    //Update the tristrips
    gpc_polygon_to_textured_tristrip(&land, &triStrips, self->texture_.pixelsHigh, self->texture_.pixelsWide);	
}

- (void) draw
{
    //CC_NODE_DRAW_SETUP();
    
    //Draw each of the land elements
    for (int i = 0; i < triStrips.num_strips; i++)
    {
        ccDrawTexturedTriStrip(triStrips.strip[i].vertex, 
                               triStrips.texCoords[i].vertex, 
                               (int)triStrips.strip[i].num_vertices, 
                               self.texture);
    }
}

- (void) dealloc
{
    gpc_free_polygon(&land);
    gpc_free_tristrip(&triStrips);
    [super dealloc];
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
