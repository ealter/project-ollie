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
#import "GameConstants.h"
#import <set>

@interface Terrain(){
    MaskedSprite *drawSprite;
    HMVectorNode *polyRenderer;
}

@property (nonatomic) TerrainTexture textureType;

+ (NSString *)fileNameForTextureType:(TerrainTexture)textureType;
- (void)initWithTextureType:(TerrainTexture)textureType shapeField:(ShapeField *)shapeField;
- (void)reproduceTouchInput;
- (void)addPointEdgeToWorld:(PointEdge*)pe;

@end

@implementation Terrain

@synthesize textureType = _textureType;

//Terrains can only be created from scratch, deserialization, or random generation
- (id)init
{
    if (self = [super init])
    {
        self.contentSize = [[CCDirector sharedDirector] winSize];
        self->shapeField_ = new ShapeField(WORLD_WIDTH, WORLD_HEIGHT);
        
        drawSprite = [[MaskedSprite alloc] initWithFile:@"rocks.png" size:CGSizeMake(WORLD_WIDTH_PX, WORLD_HEIGHT_PX)];
        drawSprite.position = drawSprite.anchorPoint = CGPointZero;
        
        polyRenderer = [HMVectorNode node]; 
        [polyRenderer setColor:ccc4f(1.0f,0.0f,0.0f,1.0f)];
        
        [self addChild:drawSprite];
        [self addChild:polyRenderer];
    }
    return self;
}

- (void)initWithTextureType:(TerrainTexture)textureType shapeField:(ShapeField *)shapeField
{
    self->shapeField_ = shapeField;
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:[[self class] fileNameForTextureType:textureType]];
    if(!texture) {
        DebugLog(@"The texture type is invalid.");
        return;
    }

    drawSprite = [[MaskedSprite alloc] initWithFile:[[self class] fileNameForTextureType:textureType] size:CGSizeMake(self.contentSize.width, self.contentSize.height)];
    drawSprite.position = drawSprite.anchorPoint = CGPointZero;
    
    polyRenderer = [[HMVectorNode alloc] init];
    [polyRenderer setColor:ccc4f(.3f,.25f,1.f,1.f)];
    
    [self addChild:drawSprite];
    [self addChild:polyRenderer];
#ifdef DEBUG
    [self reproduceTouchInput];
#endif
}

- (id)initWithTextureType:(TerrainTexture)textureType
{
    if((self = [super init])) {
        self.contentSize = [[CCDirector sharedDirector] winSize];
        self->shapeField_ = new ShapeField(self.contentSize.width, self.contentSize.height);
        assert(shapeField_);
        [self initWithTextureType:textureType shapeField:shapeField_];

    }
    return self;
}

static NSString *kTextureTypeKey = @"Texture type";
static NSString *kShapefieldKey  = @"Shapefield Data";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        TerrainTexture textureType = (TerrainTexture)[aDecoder decodeIntForKey:kTextureTypeKey];
        NSData *shapeFieldData     = [aDecoder decodeObjectForKey:kShapefieldKey];
        ShapeField *shapeField     = new ShapeField(shapeFieldData.bytes, shapeFieldData.length);
        self->shapeField_          = shapeField;
        [self initWithTextureType:textureType shapeField:shapeField];
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
#ifdef DEBUG
    static const NSString *lands[] = {@"lava",@"rocks",@"rocks2",@"rocksandvines",@"snow"};
    assert(sizeof(lands)/sizeof(*lands) == kTerrainTexture_numTextures);
    for(unsigned i=0; i<sizeof(lands)/sizeof(lands[i]); i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:(NSString *)lands[i] ofType:@"png"];
        assert([[NSFileManager defaultManager] fileExistsAtPath:path]);
    }
#endif
    switch(textureType) {
        case kTerrainTexture_lava:
            return @"lava.png";
        case kTerrainTexture_rocks:
            return @"rocks.png";
        case kTerrainTexture_ice:
            return @"snow.png";
        case kTerrainTexture_vines:
            return @"rocksandvines.png";
        case kTerrainTexture_gravel:
            return @"rocks2.png";
        default:
            return nil;
    }
}

- (void) setStrokeColor:(ccColor4F)color
{
    [polyRenderer setColor:color];
}

- (void) setTexture:(CCTexture2D *)texture
{
    [drawSprite setTexture:texture];
}

//Building land
- (void) clipCircle:(bool)add WithRadius:(float)radius x:(float)x y:(float)y
{
    shapeField_->clipCircle(add, radius, x/PTM_RATIO, y/PTM_RATIO);/*
    if (add) [drawSprite addCircleAt:ccp(x,y) radius:radius];
    else [drawSprite removeCircleAt:ccp(x,y) radius:radius];*/
}


- (void) bridgeCircles:(bool)add from:(CGPoint)p1 to:(CGPoint) p2 radiusUsed:(float)r
{
    //Compute rectangle
    //Make unit vector between the two points
    CGPoint vector = ccpSub(p2, p1);
    if (fabs(vector.x) <FLT_EPSILON && fabs(vector.y) <FLT_EPSILON) return;
    CGPoint unitvector = ccpNormalize(vector);
    
    //Rotate vector left by 90 degrees, multiply by desired width
    unitvector = ccpPerp(unitvector);
    unitvector = ccpMult(unitvector, shapeField_->getRinside(r));
    
    CGPoint p[] = { ccpAdd(p1, unitvector),
                    ccpAdd(p2, unitvector),
                    ccpSub(p2, unitvector),
                    ccpSub(p1, unitvector)};
    
    //Find x and y coords in meters, clip in shapefield
    float x[] = {p[3].x/PTM_RATIO, p[2].x/PTM_RATIO, p[1].x/PTM_RATIO, p[0].x/PTM_RATIO};
    float y[] = {p[3].y/PTM_RATIO, p[2].y/PTM_RATIO, p[1].y/PTM_RATIO, p[0].y/PTM_RATIO};
    shapeField_->clipConvexQuadBridge(add, x, y);
    /*
    if (add)
        [drawSprite addPolygon:p numPoints:4];
    else
        [drawSprite removePolygon:p numPoints:4];*/
}

- (void)shapeChanged
{
    //The shape is changed so we must update the stroke

    [polyRenderer clear];
    for (std::set<PointEdge*>::iterator i = shapeField_->peSet.begin(); i != shapeField_->peSet.end(); i++)
    {
        PointEdge* pe = *i;
        [polyRenderer drawSegmentFrom:ccp(pe->x*PTM_RATIO, pe->y*PTM_RATIO) to:ccp(pe->next->x*PTM_RATIO, pe->next->y*PTM_RATIO) radius:.03f*PTM_RATIO];
    }
    
    //Update the box2d edge shapes
    if (world) {
        //DESTROY the physical edge shapes
        for (std::set<void*>::iterator i = shapeField_->removed.begin(); i != shapeField_->removed.end(); i++)
        {
            b2Body* b = (b2Body*)*i;
            world->DestroyBody(b);
        }
        shapeField_->removed.clear();
        
        //Add the new edges
        for (std::set<PointEdge*>::iterator i = shapeField_->added.begin(); i != shapeField_->added.end(); i++)
            [self addPointEdgeToWorld:*i];
        shapeField_->added.clear();
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

- (void)reproduceTouchInput
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"touchInput.txt"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        DebugLog(@"Going to reproduce touch input");
        NSError *error = nil;
        NSString *fileData = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
        if(error) {
            DebugLog(@"Error: %@", error);
            return;
        }
        NSArray *lines = [fileData componentsSeparatedByString:@"\n"];
        CGPoint previous = CGPointMake(-1, -1);
        float previousRadius = 0;
        for(NSString *line in lines) {
            NSArray *words = [line componentsSeparatedByString:@" "];
            if(words.count < 5) continue;
            BOOL add;
            NSString *addType = [words objectAtIndex:1];
            if([addType isEqualToString:@"add"])
                add = YES;
            else if([addType isEqualToString:@"remove"])
                add = NO;
            else {
                DebugLog(@"Invalid input: %@", line);
                continue;
            }
            NSString *shapeType = [words objectAtIndex:0];
            if([shapeType isEqualToString:@"circle"]) {
                float radius = [[words objectAtIndex:2] floatValue];
                float x      = [[words objectAtIndex:3] floatValue];
                float y      = [[words objectAtIndex:4] floatValue];
                [self clipCircle:add WithRadius:radius x:x y:y];
                if(previous.x > 0 && radius == previousRadius) {
                    [self bridgeCircles:add from:previous to:ccp(x,y) radiusUsed:radius];
                }
                previous = ccp(x,y);
                previousRadius = radius;
            } 
        }
    }
}

- (void) addToWorld:(b2World*)bworld
{
    world = bworld;
    for (PeSet::iterator i = shapeField_->peSet.begin(); i != shapeField_->peSet.end(); i++)
        [self addPointEdgeToWorld:*i];
    
    shapeField_->added.clear();
    shapeField_->removed.clear();
}

- (void)addPointEdgeToWorld:(PointEdge*)pe
{
    PointEdge* npe = pe->next;
    PointEdge* nnpe = npe->next;
    PointEdge* ppe = pe->prev;
    //Create an edge shape
    b2EdgeShape e;
    e.Set(b2Vec2(0, 0), b2Vec2((npe->x - pe->x)/PTM_RATIO, (npe->y - pe->y)/PTM_RATIO));
    e.m_hasVertex0 =true;
    e.m_hasVertex3 =true;
    e.m_vertex0 = b2Vec2((ppe->x - pe->x)/PTM_RATIO, (ppe->y - pe->y)/PTM_RATIO);
    e.m_vertex3 = b2Vec2((nnpe->x - pe->x)/PTM_RATIO, (nnpe->y - pe->y)/PTM_RATIO);
    //Body def
    b2BodyDef bd;
    bd.type = b2_staticBody;
    bd.position = b2Vec2(pe->x/PTM_RATIO, pe->y/PTM_RATIO);
    bd.angle = 0;
    bd.allowSleep = true;
    b2Body* b = world->CreateBody(&bd);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &e;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.filter.categoryBits = CATEGORY_TERRAIN;
    fixtureDef.filter.maskBits = MASK_TERRAIN;
    b->CreateFixture(&fixtureDef);
    pe->userData = b;
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
