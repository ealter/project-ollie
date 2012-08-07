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
#include "GWContactListener.h"
#include "GWWeapon.h"

#define MAX_SPEED .01f
#define IMPULSE_MAG .005
#define kTagParentNode 111
#define zPivot 3

@interface GWCharacter()
{

}

-(void)generateSprites:(Bone*)root;

//private properties endemic to a character

/* The string identifier that makes this character unique to the other classes */
@property (strong, nonatomic) NSString* type;

/* An array of length 10 that holds the indices for each body part */
@property (strong, nonatomic) NSArray* spriteIndices;

/* The current orientation of the character (facing left or right normal to flat earth */
@property (assign, nonatomic) Orientation orientation;

@end
@implementation GWCharacter

@synthesize skeleton       = _skeleton;
@synthesize spriteIndices  = _spriteIndices;
@synthesize type           = _type;
@synthesize state          = _state;
@synthesize orientation    = _orientation;
@synthesize weapons        = _weapons;
@synthesize selectedWeapon = _selectedWeapon;

-(id)initWithIdentifier:(NSString *)type spriteIndices:(NSArray *)indices box2DWorld:(b2World *)world{
    
    if((self = [super init]))
    {
        self.skeleton     = [[GWSkeleton alloc]initFromFile:type box2dWorld:world];
        self.state        = kStateArming;
        self.orientation  = kOrientationLeft;
        self.type         = type;
        
        /* Add physics sprites */
        Bone* root       = [self.skeleton getBoneByName:@"Head"];
        [self addChild:[CCNode node] z:kTagParentNode tag:kTagParentNode];
        [self generateSprites:root];
        
        //if the above worked...
        if(self.skeleton) {
            /* Load animations */
            NSArray* animationNames = [NSArray arrayWithObjects:@"idle1",@"idle2",@"idle3",@"walk",@"aim", nil];            
            [self.skeleton loadAnimations:animationNames];
            
        } else {
            CCLOG(@"ERROR BUILDING SKELETONS. ABANDON ALL HOPE!");
        }
        
        /* prepare contact listener */
        [self.skeleton setOwner:self];

        

    }
    
    return self;
}

-(void)generateSprites:(Bone*)root
{
    if(root)
    {
        NSString* spriteFrameCache = [NSString stringWithFormat:@"%@%@",self.type,@"_test.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteFrameCache];
        
        NSString* spriteBatchNode  = [NSString stringWithFormat:@"%@%@",self.type,@"_test.png"];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:spriteBatchNode];
        [self addChild:spriteSheet];
        
        
        //set name to be independent of left/right
        //also adjust z order for drawing
        //
        string b_name  = root->name;
        b_name[0] = (char)tolower(b_name[0]);
        char prefix    = b_name.at(0);
        bool flipped   = false;
        if(prefix == 'r')
            b_name = b_name.substr(1);
        else if (prefix == 'l')
            b_name = b_name.substr(1); 
        CCLOG(@"The b_name is: %s and it has a z order of: %d", root->name.c_str(),index);
        NSString* name = [NSString stringWithCString:b_name.c_str() 
                                            encoding:[NSString defaultCStringEncoding]];
        NSString* spriteFrameName = [NSString stringWithFormat:@"%@%@%@%@",self.type,@"_",name,@".png"];
        
        GWPhysicsSprite *part = [GWPhysicsSprite spriteWithSpriteFrameName:spriteFrameName];
        part.physicsBody      = root->box2DBody;
        part.flipY = flipped;
        [[self getChildByTag:kTagParentNode ]addChild:part z:root->z];
        
        for(int i = 0; i < root->children.size(); i++)
            [self generateSprites:root->children.at(i)];
    }
}

-(void)loadWeapons:(NSArray *)weapons{
    
}

-(void)update:(float)dt
{
    //update skeleton's physics
    [self.skeleton update:dt];
    if(self.state != kStateRagdoll)
        [self.skeleton tieSkeletonToInteractor];
    else if([self.skeleton resting:dt])
        self.state = kStateArming;
    
    
    switch(self.state) {
        case kStateIdle:
            if(![self.skeleton animating])
            {
               /* float rand     = CCRANDOM_0_1();
                NSString* anim = @"idle1"; 
                
                if(rand < .1f)
                    anim = @"idle2";
                else if (rand < .25f)
                    anim = @"idle3";
                else if (rand < .4f)
                    anim = @"idle4";
                else if (rand < .6f)
                    anim = @"idle5";
                
                [self.skeleton runAnimation:anim flipped:self.orientation];*/
                [self.skeleton runFrame:135 ofAnimation:@"aim" flipped:self.orientation];
                
            }
            
            return;
        case kStateWalking:
        {
            if(self.orientation == kOrientationRight)
            {
                if(![self.skeleton animating])
                    [self.skeleton runAnimation:@"walk" flipped:YES];
                if(ccpLengthSQ([self.skeleton getVelocity]) <.1)
                    [self.skeleton applyLinearImpulse:ccp(-IMPULSE_MAG,0)];
            }
            else
            {
                if(![self.skeleton animating])
                    [self.skeleton runAnimation:@"walk" flipped:NO];
                if(ccpLengthSQ([self.skeleton getVelocity]) < .1)
                    [self.skeleton applyLinearImpulse:ccp(IMPULSE_MAG,0)];
                
            }
            [self.skeleton tieSkeletonToInteractor];
            return;
        }
        case kStateArming:
        {
            /* Place gun on correct bone in body */
            if(self.selectedWeapon)
            {
                Bone* targetBone;
                if(self.orientation == kOrientationLeft)
                    targetBone = [self.skeleton getBoneByName:@"ll_arm"];
                else
                    targetBone = [self.skeleton getBoneByName:@"rl_arm"];
            
                CGPoint position = ccpMult(ccp(targetBone->box2DBody->GetPosition().x,targetBone->box2DBody->GetPosition().y),PTM_RATIO);
                [self.selectedWeapon setPosition:position];
                /* Finished correct placement */
                
                /* Convert the angle to frames*/
                float angle = (self.selectedWeapon.wepAngle - [self.skeleton getAngle]) + M_PI_2;
                while(angle > M_PI*2)
                {
                    angle -= M_PI*2;
                }
                while(angle < 0)
                {
                    angle += M_PI*2;
                }
                if(angle < M_PI && self.orientation != kOrientationRight)
                    self.orientation  = kOrientationRight;
                else if(angle > M_PI && self.orientation != kOrientationLeft)
                    self.orientation = kOrientationLeft;
                
                if(angle > M_PI)
                    angle = M_PI*2 - angle;
                
                angle = RAD2DEG(angle);
                /* Finished converting angle to frames */
                
                [self.skeleton runFrame:(int)angle ofAnimation:@"aim" flipped:self.orientation];
            }
            return;
        }
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
    self.state = kStateArming;
    [self.skeleton clearAnimation];
}

-(void)setState:(characterState)state{
    //after switching from old state
    if(self.state == kStateArming)
    {
        self.selectedWeapon.visible = NO;
    }
    if(self.state == kStateRagdoll && state == kStateIdle)
    {
        [self.skeleton runAnimation:@"idle1" WithTweenTime:1.1f flipped:self.orientation];
    }
    
    
    //upon switching to new state
    _state = state;
    //[self.skeleton setActive:NO];
    if(state == kStateWalking)
    {
        self.skeleton.interactor.state = kInteractorStateActive;
        
    }
    else if (state == kStateRagdoll)
    {
        self.skeleton.interactor.state = kInteractorStateRagdoll;
        CGPoint velocity = [self.skeleton.interactor getLinearVelocity];
        [self.skeleton setVelocity:velocity];
        [self.skeleton clearAnimation];
    }
    else if (state == kStateIdle)
    {
        self.skeleton.interactor.state = kInteractorStateInactive;
    }
    else if (state == kStateArming)
    {
        self.selectedWeapon.visible = YES;
        self.skeleton.interactor.state = kInteractorStateInactive;
    }
}

-(void)setOrientation:(Orientation)orientation{
    _orientation = orientation;
    for (CCSprite* sprite in [self getChildByTag:kTagParentNode].children) {
        sprite.flipY  = self.orientation;
        
        if(!self.orientation)
            sprite.zOrder = -abs(sprite.zOrder);
        else
            sprite.zOrder = abs(sprite.zOrder);
    }
}
//override methods
-(CGPoint)position{
    
    Bone* torso = [self.skeleton getBoneByName:@"Torso"];
    CGPoint pos = ccpMult(ccp(self.skeleton.interactor.interactingBody->GetPosition().x,self.skeleton.interactor.interactingBody->GetPosition().y + torso->w/PTM_RATIO),PTM_RATIO);
    return pos;
}
-(void)setSelectedWeapon:(GWWeapon *)selectedWeapon{
    _selectedWeapon = selectedWeapon;
    selectedWeapon.holder = self;
    [[self getChildByTag:kTagParentNode]addChild:selectedWeapon z:zPivot];
}

@end
