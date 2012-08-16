//
//  GWCharacterAvatar.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/23/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWCharacterAvatar.h"
#import "GWSkeleton.h"
#import "GWCharacterModel.h"
#import "Box2D.h"
#import "GWPhysicsSprite.h"
#import "cocos2d.h"
#include "Skeleton.h"
#include "GameConstants.h"
#include "GWContactListener.h"
#include "GWWeapon.h"
#include "GWUILayer.h"

#define MAX_SPEED .01f
#define IMPULSE_MAG .005
#define kTagParentNode 111
#define zPivot 3

@interface GWCharacterAvatar()

-(void)generateSprites:(Bone*)root;
-(void)armTwoHandedGun;
-(void)armOneHandedGun;
-(void)armThrowWeapon;
-(void)armOneHandedMelee;
-(void)armTwoHandedMelee;

//private properties endemic to a character

/* An array of length 10 that holds the indices for each body part */
@property (strong, nonatomic) NSArray* spriteIndices;

@end

@implementation GWCharacterAvatar

@synthesize skeleton       = _skeleton;
@synthesize spriteIndices  = _spriteIndices;
@synthesize type           = _type;
@synthesize state          = _state;
@synthesize orientation    = _orientation;
@synthesize selectedWeapon = _selectedWeapon;
@synthesize uiLayer        = _uiLayer;
@synthesize weapons        = _weapons;

-(id)initWithModel:(GWCharacterModel *)model box2DWorld:(b2World *)world{
    
    if((self = [super init]))
    {
        DebugLog(@"This should be overwritten by subclasses! Assert to make sure it's the correct type of model.");
    }
    return self;
}

-(id)initWithIdentifier:(NSString *)type spriteIndices:(NSArray *)indices box2DWorld:(b2World *)world{
    
    if((self = [super init]))
    {
        self.skeleton       = [[GWSkeleton alloc]initFromFile:type box2dWorld:world];
        self.state          = kStateIdle;
        self.orientation    = kOrientationLeft;
        self.type           = type;
        self.weapons        = [NSMutableArray array];
        self.selectedWeapon = nil;
        
        
        /* Add physics sprites */
        Bone* root       = [self.skeleton getBoneByName:@"Head"];
        [self addChild:[CCNode node] z:kTagParentNode tag:kTagParentNode];
        [self generateSprites:root];

        
        //if the above worked...
        if(self.skeleton) {
            /* Load animations */
            NSArray* animationNames = [NSArray arrayWithObjects:@"idle1",@"idle2",@"idle3",@"walk",@"moonwalk",@"aimgun2", @"throwaim",@"throwhigh",@"throwmed" nil];            
            [self.skeleton loadAnimations:animationNames];
            
        } else {
            CCLOG(@"ERROR BUILDING SKELETONS. ABANDON ALL HOPE!");
        }
        
        /* prepare contact listener */
        [self.skeleton setOwner:self]; 
        
        [self scheduleUpdate];
        
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
        if(prefix == 'r' || prefix == 'l')
            b_name = b_name.substr(1);
        
        //Determine if the bone needs an image
        prefix = b_name.at(0);
        GWPhysicsSprite *part;
        //If it isn't an upper body part, we need to get the correct image
       // if(prefix != 'u')
        {
            NSString* name = [NSString stringWithCString:b_name.c_str() 
                                                encoding:[NSString defaultCStringEncoding]];
            NSString* spriteFrameName = [NSString stringWithFormat:@"%@%@%@%@",self.type,@"_",name,@".png"];
            
            part = [GWPhysicsSprite spriteWithSpriteFrameName:spriteFrameName];
            part.flipY = flipped;
        }
        //If it is an upper body part, we don't need to show it
        /*else
        {
            part = [GWPhysicsSprite node];
        }*/
        //set its physics body correctly
        part.physicsBody      = root->box2DBody;
        [[self getChildByTag:kTagParentNode]addChild:part z:root->z];
        
        for(int i = 0; i < root->children.size(); i++)
            [self generateSprites:root->children.at(i)];
    }
}

/*- (NSArray *)weapons
{
    return self.model.copy;
}*/

-(void)loadWeapons:(NSArray *)weapons
{
    [self.weapons addObjectsFromArray:weapons];
    //[self.model.availableWeapons addObjectsFromArray:weapons];
}

- (GWCharacterModel *)model
{
    DebugLog(@"Subclasses should override this!!!");
    return nil;
}

-(void)update:(float)dt
{
    //update skeleton's physics
    [self.skeleton update:dt];
    if(self.state != kStateRagdoll)
    {
        
        if(ccpLengthSQ(self.skeleton.getVelocity) > 5)
        {
            self.state = kStateRagdoll;
        }
        else
            [self.skeleton tieSkeletonToInteractor];
    }
    else if([self.skeleton resting:dt])
        self.state = kStateIdle;
    
    switch(self.state) {
        case kStateIdle:
            if(![self.skeleton animating]) {
                float rand     = CCRANDOM_0_1();
                NSString* anim = @"idle1"; 
                
                if(rand < .25f)
                    anim = @"idle2";
                else if (rand < .4f)
                    anim = @"idle3";
                /*else if (rand < .4f)
                    anim = @"idle4";
                else if (rand < .6f)
                    anim = @"idle5";*/
                
                [self.skeleton runAnimation:anim flipped:self.orientation];
            }
            return;
        case kStateWalking:
            if(![self.skeleton animating])
                [self.skeleton runAnimation:@"walk" flipped:self.orientation];
            if(ccpLengthSQ([self.skeleton getVelocity]) < .1)
                [self.skeleton applyLinearImpulse:ccp(IMPULSE_MAG*(1 - 2.*self.orientation),0)];
            [self.skeleton tieSkeletonToInteractor];
            return;
        case kStateArming:
            // if holding a weapon
            if(self.selectedWeapon)
            {
                [self armTwoHandedGun];
                
            }
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
    self.state = kStateIdle;
    [self.skeleton clearAnimation];
}

-(void)setState:(characterState)state{
    //after switching from old state
    
    // from ragdoll to idle
    if(_state == kStateRagdoll && state == kStateIdle)
        [self.skeleton runAnimation:@"idle1" WithTweenTime:1.1f flipped:self.orientation];
    
    // from arming to not arming
    else if (_state == kStateArming && state != kStateArming)
    {
        [[self getChildByTag:kTagParentNode]removeChild:self.selectedWeapon cleanup:YES];
        self.selectedWeapon   = nil;
    }
    
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
        self.skeleton.interactor.state = kInteractorStateInactive;
    }
    
    
    //upon switching to new state
    _state = state;
}

-(void)setOrientation:(Orientation)orientation{
    _orientation = orientation;
    for (CCSprite* sprite in [self getChildByTag:kTagParentNode].children) {
        sprite.flipY  = !self.orientation;
        
        if(!self.orientation)
            sprite.zOrder = -abs(sprite.zOrder);
        else
            sprite.zOrder = abs(sprite.zOrder);
    }
}


/***********************
 *** Weapon Handling ***
 ***********************/

-(void)armTwoHandedGun{
    
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
    
    [self.skeleton runFrame:(int)angle ofAnimation:@"aimgun2" flipped:self.orientation];
}


/***********************
 *** Parent Override ***
 ***********************/

-(CGPoint)position{
    
    //gets the interactor's x and the torso's y. Weird huh?
    Bone* torso = [self.skeleton getBoneByName:@"Torso"];
    CGPoint pos = ccpMult(ccp([self.skeleton.interactor getPosition].x,torso->box2DBody->GetPosition().y),PTM_RATIO);
    return pos;
}

-(void)setSelectedWeapon:(GWWeapon *)selectedWeapon{
    if(selectedWeapon != nil)
    {
        _selectedWeapon = selectedWeapon;
        selectedWeapon.holder = self;
        [[self getChildByTag:kTagParentNode]addChild:selectedWeapon z:zPivot];
        self.state = kStateArming;
        [self setOrientation:self.orientation];
    }
}

/************************
 *** Gesture Handling ***
 ************************/

-(void)handleSwipeRightWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}

-(void)handleSwipeLeftWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}

-(void)handleSwipeUpWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}

-(void)handleSwipeDownWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (self.state == kStateArming) {
        [((GWWeapon <GestureChild>*) self.selectedWeapon) handlePanWithStart:startPoint andCurrent:currPoint andTime:time];
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint) endPoint andTime:(float) time
{
    if (self.state == kStateArming) {
        [((GWWeapon <GestureChild>*) self.selectedWeapon) handlePanFinishedWithStart:startPoint andEnd:endPoint andTime:time];
    }
}

-(void)handleTap:(CGPoint) tapPoint
{
    if (self.state == kStateArming) {
        {
           [((GWWeapon <GestureChild>*) self.selectedWeapon) handleTap:tapPoint]; 
        }
    }else {
        [self.uiLayer buildWeaponTableFrom:self];
        ActionLayer* al = (ActionLayer*)self.parent;
        [al.camera followNode:self];
        
    }
}

@end
