//
//  Terrain.m
//  ProjectOllie
//
//  Created by Lion User on 6/4/12.
//  Copyright 2012 hi ku llc All rights reserved.
//

#import "Terrain.h"
#import "ccMacros.h"

@implementation Terrain

@synthesize texture = texture_;

- (id) initWithTexture:(CCTexture2D*)t
{
    if(self = [super init])
    {
        self->texture_ = t;
        self->triStrips.num_strips = 0;
        self->triStrips.strip = nil;
        self->triStrips.texCoords = nil;
        self->land.num_contours = 0;
        self->land.contour = nil;
    }
    return self;
}

//Building land
- (void) addPolygon:(gpc_polygon*)p
{
    if (p->num_contours == 0) return;
    //Add to the current land
    gpc_polygon* final = new gpc_polygon;
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
        for (int i = 0; i < b2Bodies.size(); i++)
            world->DestroyBody((b2Body*)b2Bodies.at(i));
        b2Bodies.clear();
        
        //Create new bodies, one chain shape for each beautiful contour
        for (int i = 0; i < land.num_contours; i++)
        {
            //Convert the array into b2Vec2 verticies
            vertex_list gpcVerts = land.contour[i];
            b2Vec2 *b2Verts = new b2Vec2[gpcVerts.num_vertices];
            for (int j = 0; j < gpcVerts.num_vertices; j++)
                b2Verts[j].Set(gpcVerts.vertex[j].x, gpcVerts.vertex[j].y);
            //Make the chain shape loop
            b2ChainShape landShape;
            landShape.CreateLoop(b2Verts, gpcVerts.num_vertices);
            
            //Create a body from the definition
            b2BodyDef bdef;
            bdef.position.Set(0, 0);
            b2Body* body = world->CreateBody(&bdef);
            body->CreateFixture(&landShape, 0.0f);
            b2Bodies.push_back(body);
            
            //Clean up
            delete b2Verts;
        }
    }
    
    //Update the tristrips
    //  gpc_free_tristrip(&triStrips);
    gpc_polygon_to_textured_tristrip(&land, &triStrips, self->texture_.pixelsHigh, self->texture_.pixelsWide);
}

- (void) draw
{
    //CC_NODE_DRAW_SETUP();
    ccGLEnable( glServerState_ );																\
 //   NSAssert(shaderProgram_, @"No shader program set for node: terrain");                       \
//	[shaderProgram_ use];																		\//
//	[shaderProgram_ setUniformForModelViewProjectionMatrix];	
    
    //Draw each of the land elements
    for (int i = 0; i < triStrips.num_strips; i++)
    {
        ccDrawTexturedTriStrip(triStrips.strip[i].vertex,
                               triStrips.texCoords[i].vertex,
                               triStrips.strip[i].num_vertices,
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
