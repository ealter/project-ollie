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
#import <set>

@interface Terrain(){
    MaskedSprite *drawSprite;
    HMVectorNode *polyRenderer;
}

@property (nonatomic) TerrainTexture textureType;

+ (NSString *)fileNameForTextureType:(TerrainTexture)textureType;
- (void)initWithTextureType:(TerrainTexture)textureType shapeField:(ShapeField *)shapeField;
- (void)reproduceTouchInput;

@end

@implementation Terrain

@synthesize texture = texture_;
@synthesize textureType = _textureType;

- (void)initWithTextureType:(TerrainTexture)textureType shapeField:(ShapeField *)shapeField
{
    self->shapeField_ = shapeField;
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:[[self class] fileNameForTextureType:textureType]];
    if(!texture) {
        DebugLog(@"The texture type is invalid.");
        return;
    }
    self->texture_ = texture;

    drawSprite = [[MaskedSprite alloc] initWithFile:[[self class] fileNameForTextureType:textureType] size:CGSizeMake(self.contentSize.width, self.contentSize.height)];
    drawSprite.position = drawSprite.anchorPoint = CGPointZero;
    
    polyRenderer = [[HMVectorNode alloc] init];
    
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
    static const NSString *lands[] = {@"lava"};
    assert(sizeof(lands)/sizeof(*lands) == kTerrainTexture_numTextures);
    for(unsigned i=0; i<sizeof(lands)/sizeof(lands[i]); i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:(NSString *)lands[i] ofType:@"png"];
        assert([[NSFileManager defaultManager] fileExistsAtPath:path]);
    }
#endif
    switch(textureType) {
        case kTerrainTexture_lava:
            return @"lava.png";
        default:
            return nil;
    }
}

//Building land
- (void) clipCircle:(bool)add WithRadius:(float)radius x:(float)x y:(float)y
{
    shapeField_->clipCircle(add, radius, x, y);
    if (add) [drawSprite addCircleAt:ccp(x,y) radius:radius];
    else [drawSprite removeCircleAt:ccp(x,y) radius:radius];
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
    
    CGPoint p[] = { ccpAdd(p1,      unitvector),
                    ccpAdd(p2, unitvector),
                    ccpSub(p2, unitvector),
                    ccpSub(p1,      unitvector)};
    
    float x[] = {p[3].x, p[2].x, p[1].x, p[0].x};
    float y[] = {p[3].y, p[2].y, p[1].y, p[0].y};
    shapeField_->clipConvexQuadBridge(add, x, y);
    if (add) [drawSprite addPolygon:p numPoints:4];
    else [drawSprite removePolygon:p numPoints:4];
}

- (void)shapeChanged
{
    //The shape is changed so we must update the stroke

    [polyRenderer clear];
    for (std::set<PointEdge*>::iterator i = shapeField_->peSet.begin(); i != shapeField_->peSet.end(); i++)
    {
        PointEdge* pe = *i;
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

- (void)reproduceTouchInput
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"touchInput.txt"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        DebugLog(@"Going to reproduce touch input");
        NSError *error = nil;
        DebugLog(@"The path is %@", path);
        NSString *fileData = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
        if(error) {
            DebugLog(@"Error: %@", error);
            return;
        }
        NSArray *lines = [fileData componentsSeparatedByString:@"\n"];
        DebugLog(@"The lines are %@", lines);
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
                if(add)
                    [self addCircleWithRadius:radius x:x y:y];
                else
                    [self removeCircleWithRadius:radius x:x y:y];
            } else if([shapeType isEqualToString:@"rect"]) {
                CGPoint points[4];
                int wordsBaseIndex = 2;
                for(int i=0; i<4; i++)
                    points[i].x = [[words objectAtIndex:i + wordsBaseIndex] floatValue];
                wordsBaseIndex += 4;
                for(int i=0; i<4; i++)
                    points[i].y = [[words objectAtIndex:i + wordsBaseIndex] floatValue];
                if(add)
                    [self addQuadWithPoints:points];
                else
                    [self removeQuadWithPoints:points];
            }
        }
    }
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
