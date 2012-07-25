//
//  GWCharacter.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/23/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWCharacter.h"
#import "GWSkeleton.h"
#import "Box2D.h"
#import "GWPhysicsSprite.h"
#include "Skeleton.h"

@interface GWCharacter()
{
    
}

-(void)generateSprites:(Bone*)root index:(int)index;

//private properties endemic to a character

/* The GWSkeleton that acts as a ragdoll/animates the character */
@property (strong, nonatomic) GWSkeleton* skeleton;

/* The string identifier that makes this character unique to the other classes */
@property (strong, nonatomic) NSString* type;

/* An array of length 10 that holds the indices for each body part */
@property (strong, nonatomic) NSArray* spriteIndices;

@end
@implementation GWCharacter

@synthesize skeleton      = _skeleton;
@synthesize spriteIndices = _spriteIndices;
@synthesize type          = _type;

-(id)initWithIdentifier:(NSString *)type spriteIndices:(NSArray *)indices box2DWorld:(b2World *)world{
    
    if((self = [super init]))
    {
        self.skeleton = [[GWSkeleton alloc]initFromFile:type box2dWorld:world];
        Bone* root = [self.skeleton getBoneByName:@"head"];
        [self generateSprites:root index:0];
    }
    
    return self;
}

-(void)generateSprites:(Bone*)root index:(int)index
{
    if(root)
    {
        NSString* spriteFrameCache = [NSString stringWithFormat:@"%@%@",self.type,@".plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteFrameCache];
        
        NSString* spriteBatchNode  = [NSString stringWithFormat:@"%@%@",self.type,@".png"];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:spriteBatchNode];
        [self addChild:spriteSheet];
        
        NSString* name = [NSString stringWithCString:root->name.c_str() 
                                            encoding:[NSString defaultCStringEncoding]];
        NSString* spriteFrameName = [NSString stringWithFormat:@"%@%@%@%@%d%@",self.type,@"_",name,@"_",index,@".png"];
        
        GWPhysicsSprite *part     = [GWPhysicsSprite spriteWithSpriteFrameName:spriteFrameName];
        [self addChild:part];
    }
}

@end
