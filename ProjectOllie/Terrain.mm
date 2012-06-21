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
#import "MaskedSprite.h"
#import "HMVectorNode.h"

@interface Terrain(){
    MaskedSprite *drawSprite;
    HMVectorNode *polyRenderer;
}
@end

@implementation Terrain

@synthesize texture = texture_;

- (id) initWithTexture:(CCTexture2D*)t
{
    if(self = [super init])
    {
        self->shapeField = new ShapeField(1024, 768);
        self->texture_ = t;
        
        drawSprite = [[MaskedSprite alloc] initWithFile:@"snow.png" size:CGSizeMake(1024,768)];
        drawSprite.position = drawSprite.anchorPoint = ccp(0,0);
        
        polyRenderer = [[HMVectorNode alloc] init];
        [self addChild:polyRenderer];
    }
    return self;
}

//Building land
- (void) addCircleWithRadius:(float)r x:(float)x y:(float)y
{
    shapeField->clipCircle(true, r, x, y);
    
    //part of drawing, unrelated to terrain
    [drawSprite drawCircleAt:ccp(x,y) withRadius:r Additive:YES];
    
    
}

- (void) removeCircleWithRadius:(float)r x:(float)x y:(float)y
{
    shapeField->clipCircle(false, r, x, y);
    
    //part of drawing, unrelated to terrain
    [drawSprite drawCircleAt:ccp(x,y) withRadius:r Additive:NO];
}

- (void) draw
{
    //CC_NODE_DRAW_SETUP();
    ccGLEnable( glServerState_ );
    [drawSprite draw];
    [polyRenderer clear];
    int numLines = shapeField->peSet.size()*2;
    ccVertex2F* points = new ccVertex2F[numLines];
    for (int i = 0; i < shapeField->peSet.size(); i++)
    {
        points[i*2].x = shapeField->peSet[i]->x;
        points[i*2].y = shapeField->peSet[i]->y;
        points[i*2+1].x = shapeField->peSet[i]->next->x;
        points[i*2+1].y = shapeField->peSet[i]->next->y;
        
        CGPoint p1 = ccp(points[i*2].x, points[i*2].y);
        CGPoint p2 = ccp(points[i*2+1].x,points[i*2+1].y);
        [polyRenderer drawSegmentFrom:p1 to:p2 radius:1.3f color:ccc4f(.2f,.4f,.8f,1)];
    }
    
}

- (void) clear
{
    //Clear the shape field
    shapeField->clear();
    [drawSprite clear];
    [polyRenderer clear];
}

- (void) dealloc
{
    delete shapeField;
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
