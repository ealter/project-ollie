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

- (id) initWithTexture:(CCTexture2D*)t
{
    if(self = [super init])
    {
        self->texture_ = t;
        self->landBlocks = [NSMutableArray array];
    }
    return self;
}

//Building land
- (void) addPolygon:(gpc_polygon*)p
{
    //Check which polygons it intersects
    for (int i = 0; i < [self->landBlocks count]; i++)
        if (gpc_intersects(((LandBlock*)[self->landBlocks objectAtIndex:i]).poly, p))
        {
            //Add to the land block polygon at i
            LandBlock* intersectingLandBlock = (LandBlock*)[self->landBlocks objectAtIndex:i];
            gpc_polygon* unioned = (gpc_polygon*) malloc(sizeof(*unioned));
            gpc_polygon_clip(GPC_UNION, intersectingLandBlock.poly, p, unioned);
            
            //Free the useless old land
            gpc_free_polygon(intersectingLandBlock.poly);
            
            //Set it to the new land
            intersectingLandBlock.poly = unioned;
            
            //Add any other polygons that also intersect p to the polygon at i
            for (int j = i + 1; j < [self->landBlocks count]; j++)
                if (gpc_intersects(((LandBlock*)[self->landBlocks objectAtIndex:j]).poly, p))
                {
                    LandBlock* overlaping = (LandBlock*)[self->landBlocks objectAtIndex:j];
                    unioned = (gpc_polygon*) malloc(sizeof(*unioned));
                    gpc_polygon_clip(GPC_UNION, intersectingLandBlock.poly, overlaping.poly, unioned);
                    
                    //Free the useless old land
                    gpc_free_polygon(intersectingLandBlock.poly);
                    
                    //Set it to the new land
                    intersectingLandBlock.poly = unioned;
                    
                    //Remove element j from the array since it now is part of element i
                    [self->landBlocks removeObject:overlaping];
                    
                    //Get rid of that garbage
                    [overlaping dealloc];
                    
                    j--;
                }
            //Recalculate the derived components of the LandBlock at i
            [intersectingLandBlock shapeChanged];
            return; //Done
        }
    
    //No intersecting LandBlock to add to, make a new one
    [landBlocks addObject:[[LandBlock alloc] initWithPoly:p]];
}

//Removing land
- (void) removeCircleWithRadius:(float)r x:(float)x y:(float)y
{
    
}

- (void) removePolygon:(gpc_polygon*)p
{
    
}

- (void) draw
{
    CC_NODE_DRAW_SETUP();
    
    //Draw each of the land elements
    for (LandBlock* L in landBlocks) 
        for (int i = 0; i < L.triStrip->num_strips; i++)
        {
            ccDrawTexturedTriStrip(L.triStrip->strip[i].vertex, 
                                   L.triStrip->texCoords[i].vertex, 
                                   (int)L.triStrip->strip[i].num_vertices, 
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

/* LandBlock Helper Class */

@implementation LandBlock
@synthesize poly = _poly, body = _body, triStrip = _triStrip;
- (id) initWithPoly:(gpc_polygon*)p
{
    if (self = [super init])
    {
        self->_poly = p;
        [self shapeChanged];
    }
    return self;
}
- (void) shapeChanged
{
    //Update physics body
    if (self->_body)
    {
        
        //Remove from world
        //Deallocate
    }
    //Create new chain shapes
    
    //Add back to the world
    
    //Update textured tristrip for drawing
    gpc_free_tristrip(self->_triStrip);
    
    
}
- (void) dealloc
{
    //Remove the physics body from the world
    
    //Release the physics body
    
    //Free the c structs
    gpc_free_tristrip(self->_triStrip);
    gpc_free_polygon(self->_poly);
    delete(self->_triStrip);
    delete(self->_poly);
    
    [super dealloc];
}
@end
                           
                           
