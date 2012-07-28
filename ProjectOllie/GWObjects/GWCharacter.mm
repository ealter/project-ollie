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
#include "GameConstants.h"

#define MAX_SPEED .01f
#define IMPULSE_MAG .0001

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

/* The current state of the GWCharacter */
@property (assign, nonatomic) characterState state;

/* The current orientation of the character (facing left or right normal to flat earth */
@property (assign, nonatomic) Orientation orientation;

@end
@implementation GWCharacter

@synthesize skeleton      = _skeleton;
@synthesize spriteIndices = _spriteIndices;
@synthesize type          = _type;
@synthesize state         = _state;
@synthesize orientation   = _orientation;

-(id)initWithIdentifier:(NSString *)type spriteIndices:(NSArray *)indices box2DWorld:(b2World *)world{
    
    if((self = [super init]))
    {
        self.skeleton    = [[GWSkeleton alloc]initFromFile:type box2dWorld:world];
        self.state       = kStateIdle;
        self.orientation = kOrientationLeft;
        
        Bone* root    = [self.skeleton getBoneByName:@"head"];
        [self generateSprites:root index:0];
        
        //if the above worked...
        if(self.skeleton) {
            /* Load animations */
            NSArray* animationNames = [NSArray arrayWithObjects:@"sprinting",@"woopwoop",@"idle1",@"idle2",@"idle3",@"idle4",@"idle5", nil];            
            [self.skeleton loadAnimations:animationNames];
            
        } else {
            CCLOG(@"ERROR BUILDING SKELETONS. ABANDON ALL HOPE!");
        }

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
        
        GWPhysicsSprite *part = [GWPhysicsSprite spriteWithSpriteFrameName:spriteFrameName];
        [self addChild:part];
    }
}

-(void)update:(float)dt
{
    //update skeleton's physics
    [self.skeleton update:dt];
    if(self.state != kStateRagdoll)
        [self.skeleton tieSkeletonToInteractor];
    
    
    float speedSQ = ccpLengthSQ([self.skeleton getVelocity]);
    if([self.skeleton calculateNormalAngle] && self.state != kStateWalking && speedSQ < MAX_SPEED)
        self.state = kStateIdle;
    
    switch(self.state) {
        case kStateIdle:
            if(![self.skeleton animating])
            {
                float rand     = CCRANDOM_0_1();
                NSString* anim = @"idle1"; 
                if(rand < .2f)
                    anim = @"idle2";
                else if (rand < .4f)
                    anim = @"idle3";
                else if (rand < .6f)
                    anim = @"idle4";
                else if (rand < .8f)
                    anim = @"idle5";
                
                [self.skeleton runAnimation:anim WithTweenTime:.4 flipped:self.orientation];
            }
            
            return;
        case kStateWalking:
        {
            if(self.orientation == kOrientationLeft)
            {
                if(![self.skeleton animating])
                    [self.skeleton runAnimation:@"sprinting" flipped:YES];
                if(ccpLengthSQ([self.skeleton getVelocity]) <.1)
                    [self.skeleton applyLinearImpulse:ccp(-IMPULSE_MAG,0)];
            }
            else
            {
                if(![self.skeleton animating])
                    [self.skeleton runAnimation:@"sprinting" flipped:NO];
                if(ccpLengthSQ([self.skeleton getVelocity]) < .1)
                    [self.skeleton applyLinearImpulse:ccp(IMPULSE_MAG,0)];
            }
            return;
        }
        case kStateArming:
            return;
        case kStateManeuvering:
            return;
        case kStateRagdoll:
            [self.skeleton clearAnimation];
            [self.skeleton setInteractorPositionInRagdoll];
            return;
    }
    
}

-(void)walkLeft{
    
    // If it is making contact with some ground body
    if([self.skeleton calculateNormalAngle])
    {
        self.orientation = kOrientationLeft;
        self.state       = kStateWalking;
        [self.skeleton clearAnimation];
    }

}

-(void)walkRight{
    
    // If it is making contact with some ground body
    if([self.skeleton calculateNormalAngle])
    {
        self.orientation = kOrientationRight;
        self.state       = kStateWalking;
        [self.skeleton clearAnimation];
    }
    
}

-(void)stopWalking{
    self.state = kStateRagdoll;
    [self.skeleton clearAnimation];
}

-(void)setState:(characterState)state{
    _state = state;
    if(state == kStateWalking)
    {
        self.skeleton.interactor.state = kInteractorStateActive;
        //CGPoint velocity = [self.skeleton getVelocity];
        //[self.skeleton.interactor setLinearVelocity:velocity];
        //[self.skeleton.interactor setAngularVelocity:0];
    }
    else if (state == kStateRagdoll)
    {
        self.skeleton.interactor.state = kInteractorStateRagdoll;
        CGPoint velocity = [self.skeleton.interactor getLinearVelocity];
        [self.skeleton setVelocity:velocity];
        
        [self.skeleton clearAnimation];
    }
    else if (state == kStateIdle)
        self.skeleton.interactor.state = kInteractorStateInactive;
}

@end
