//
//  Terrain.m
//  ProjectOllie
//
//  Created by Steve Gregory on 6/4/12.
//  Copyright 2012 hi ku llc All rights reserved.
//

#import "Terrain.h"
#import "cocos2d.h"
#import "ShapeField.h"
#import "PointEdge.h"
#import "ccMacros.h"
#import "MaskedSprite.h"
#import "HMVectorNode.h"
#import "Box2D.h"

@interface Terrain(){
    MaskedSprite *drawSprite;
    HMVectorNode *polyRenderer;
}

@property (nonatomic) TerrainTexture textureType;

+ (NSString *)fileNameForTextureType:(TerrainTexture)textureType;
- (id)initWithTextureType:(TerrainTexture)textureType shapeField:(ShapeField *)shapeField;

@end

@implementation Terrain

@synthesize texture = texture_;
@synthesize textureType = _textureType;

- (id)initWithTextureType:(TerrainTexture)textureType shapeField:(ShapeField *)shapeField
{
    self->shapeField_ = shapeField;
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:[[self class] fileNameForTextureType:textureType]];
    if(!texture) {
        DebugLog(@"The texture type is invalid.");
        return nil;
    }
    self->texture_ = texture;
    
    drawSprite = [[MaskedSprite alloc] initWithFile:@"lava.png" size:CGSizeMake(self.contentSize.width, self.contentSize.height)];
    drawSprite.position = drawSprite.anchorPoint = CGPointZero;
    
    polyRenderer = [[HMVectorNode alloc] init];
    [self addChild:drawSprite];
    [self addChild:polyRenderer];
    return self;
}

- (id)initWithTextureType:(TerrainTexture)textureType
{
    if(self = [super init]) {
        self.contentSize = [[CCDirector sharedDirector] winSize];
        self->shapeField_ = new ShapeField(self.contentSize.width, self.contentSize.height);
        self = [self initWithTextureType:textureType shapeField:shapeField_];
    }
    return self;
}

static NSString *kTextureTypeKey = @"Texture type";
static NSString *kShapefieldKey  = @"Shapefield Data";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    TerrainTexture textureType = (TerrainTexture)[aDecoder decodeIntForKey:kTextureTypeKey];
    NSData *shapeFieldData     = [aDecoder decodeObjectForKey:kShapefieldKey];
    ShapeField *shapeField     = new ShapeField(shapeFieldData.bytes, shapeFieldData.length);
    if( self = [self initWithTextureType:textureType shapeField:shapeField]) {
        //TODO: Update the mask with the shapefield info
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.textureType forKey:kTextureTypeKey];
    int shapeFieldNumBytes = 0;
    void *shapeFieldBytes = shapeField_->pickleDataStructure(shapeFieldNumBytes);
    NSData *shapeFieldData = [NSData dataWithBytes:shapeFieldBytes length:shapeFieldNumBytes];
    [aCoder encodeObject:shapeFieldData forKey:kShapefieldKey];
}

+ (NSString *)fileNameForTextureType:(TerrainTexture)textureType
{
    switch(textureType) {
        case TerrainTexture_pattern1:
            return @"pattern1.png";
        default:
            return nil;
    }
}

//Building land
- (void)addCircleWithRadius:(float)radius x:(float)x y:(float)y
{
    shapeField_->clipCircle(true, radius, x, y);
    [drawSprite addCircleAt:ccp(x,y) radius:radius];
    [self shapeChanged];
}

- (void)addQuadWithPoints:(CGPoint[])p
{
    float x[] = {p[0].x, p[1].x, p[2].x, p[3].x};
    float y[] = {p[0].y, p[1].y, p[2].y, p[3].y};
    shapeField_->clipConvexQuad(true, x, y);
    [drawSprite addPolygon:p numPoints:4];
    [self shapeChanged];
}

//Removing land
- (void)removeCircleWithRadius:(float)radius x:(float)x y:(float)y
{
    shapeField_->clipCircle(false, radius, x, y);
    [drawSprite removeCircleAt:ccp(x,y) radius:radius];
    [self shapeChanged];
}

- (void)removeQuadWithPoints:(CGPoint[])p
{
    float x[] = {p[0].x, p[1].x, p[2].x, p[3].x};
    float y[] = {p[0].y, p[1].y, p[2].y, p[3].y};
    shapeField_->clipConvexQuad(false, x, y);
    [drawSprite removePolygon:p numPoints:4];
    [self shapeChanged];
}

- (void)shapeChanged
{
    //The shape is changed so we must update the stroke
    [polyRenderer clear];
    for (int i = 0; i < shapeField_->peSet.size(); i++) {
        PointEdge* pe = shapeField_->peSet[i];
        [polyRenderer drawSegmentFrom:ccp(pe->x, pe->y) to:ccp(pe->next->x, pe->next->y) radius:1.3f color:ccc4f(.2f,.4f,.8f,1)];
    }
}

- (void)clear
{
    //Clear the shape field
    shapeField_->clear();
    [drawSprite clear];
    [polyRenderer clear];
}

- (void)dealloc
{
    delete shapeField_;
}

/* Random Land Generators */

+ (Terrain*)generateRandomOneIsland
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
