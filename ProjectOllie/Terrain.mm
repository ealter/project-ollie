//
//  Terrain.m
//  ProjectOllie
//
//  Created by Lion User on 6/4/12.
//  Copyright 2012 hi ku llc All rights reserved.
//

#import "Terrain.h"
#import "ShapeField.h"
#import "PointEdge.h"
#import "ccMacros.h"

@implementation Terrain

@synthesize texture = texture_;

- (id) initWithTexture:(CCTexture2D*)t
{
    if(self = [super init])
    {
        self->shapeField = new ShapeField(1024, 768);
        self->texture_ = t;
    }
    return self;
}

//Building land
- (void) addCircleWithRadius:(float)r x:(float)x y:(float)y
{
    shapeField->clipCircle(true, r, x, y);
}

- (void) removeCircleWithRadius:(float)r x:(float)x y:(float)y
{
    shapeField->clipCircle(false, r, x, y);
}

- (void) draw
{
    //CC_NODE_DRAW_SETUP();
    ccGLEnable( glServerState_ );
    /*
    //Draw each of the land elements
    for (int i = 0; i < triStrips.num_strips; i++)
    {
        ccDrawTexturedTriStrip(triStrips.strip[i].vertex,
                               triStrips.texCoords[i].vertex,
                               triStrips.strip[i].num_vertices,
                               self.texture);
        //Debug draw triangle lines
        int numVerts = triStrips.strip[i].num_vertices;
        for (int j = 0; j < numVerts-1; j++){
            ccDrawLine(ccp(triStrips.strip[i].vertex[j].x, triStrips.strip[i].vertex[j].y),
                       ccp(triStrips.strip[i].vertex[j+1].x, triStrips.strip[i].vertex[j+1].y));
        }
        if (numVerts > 1)
            ccDrawLine(ccp(triStrips.strip[i].vertex[numVerts-1].x, triStrips.strip[i].vertex[numVerts-1].y),
                       ccp(triStrips.strip[i].vertex[0].x, triStrips.strip[i].vertex[0].y));
    }
    */
    for (int i = 0 ; i < shapeField->peSet.size(); i++)
    ccDrawLine(ccp(shapeField->peSet[i]->x, shapeField->peSet[i]->y),
               ccp(shapeField->peSet[i]->next->x, shapeField->peSet[i]->next->y));
    
}

- (void) clear
{
    //Clear the shape field
   // ShapeField.clear();
}

- (void) dealloc
{
    
    [super dealloc];
}

/* Random Land Generators */

+ (Terrain*) generateRandomOneIsland
{
    return nil;
}

+ (Terrain*) generateRandomTwoIsland
{
    return nil;
}

+ (Terrain*) generateRandomBlobs
{
    return nil;
}

+ (Terrain*) generateRandomCavern
{
    return nil;
}

@end
