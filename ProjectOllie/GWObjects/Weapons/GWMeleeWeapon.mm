//
//  GWMeleeWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWMeleeWeapon.h"
#import "HMVectorNode.h"
#import "GameConstants.h"


@implementation GWMeleeWeapon
@synthesize weaponLength    = _weaponLength;
@synthesize meleeImage      = _meleeImage;

- (id)initWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo wepLength:(float)length box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super init]) {
        //Set weapon position and properties
        self.position       = ccpMult(pos, PTM_RATIO);
        self.contentSize    = CGSizeMake(size.width * PTM_RATIO, size.height * PTM_RATIO);
        self.ammo           = ammo;
        self.weaponLength   = length;
        _world              = world;
        self.gameWorld      = gWorld;
        self.weaponImage    = imageName;
        self.meleeImage     = [CCSprite spriteWithFile:imageName];
        self.meleeImage.position= ccpAdd(self.meleeImage.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        self.meleeImage.rotation = 0;
        
        [self fillDescription];
        
        //Make the drawnode and set the color
        drawNode            = [HMVectorNode node];
        drawNode.position   = ccpAdd(drawNode.position, CGPointMake(self.contentSize.width/4, self.contentSize.height/4));
        ccColor4F c         = ccc4f(.5f,.5f,0.f,.5f);
        [drawNode setColor:c];
        
        //Add children
        [self addChild:drawNode];    
        [self addChild:self.meleeImage];
    }
    return self;
}

//You should override this!  This is where events unique to the weapon happen
-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {        
        [self applyb2ForceInRadius:self.weaponLength/PTM_RATIO withStrength:0.1 isOutwards:YES aimedRight:swingRight];
        //Clear drawNode, decrement ammo
        [drawNode clear];
        self.ammo--;
    }else {
        //Out of ammo!
    }
}

-(BOOL)calculateMeleeDirectionFromStart:(CGPoint) startPoint toAimPoint:(CGPoint) aimPoint
{
    BOOL isRight    = NO;
    self.wepAngle   = M_PI;
    if (startPoint.x < aimPoint.x) {
        isRight     = YES;
        self.wepAngle = 0;
    }
    swingRight      = isRight;
    return isRight;
}

-(void)simulateMeleeWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint
{
    //Clear HMVectorNode
    [drawNode clear];
    BOOL isRight = [self calculateMeleeDirectionFromStart:self.holder.position toAimPoint:currPoint];
    //Melee simulation    
    int numPoints = 7;
    for (int i = 0; i < numPoints ; i++) {
        float angle     = ((120./numPoints) * i) - 45;
        angle           = CC_DEGREES_TO_RADIANS(angle);
        CGPoint drawPoint = CGPointMake(drawNode.position.x + cosf(angle) * self.weaponLength * PTM_RATIO, drawNode.position.y + sinf(angle) * self.weaponLength * PTM_RATIO);
        
        CGPoint pointA  = ccp(drawPoint.x + cosf(angle + M_PI/2)*3., drawPoint.y + sinf(angle + M_PI/2)*3.);
        CGPoint pointB  = ccpSub(drawPoint, pointA);
        pointB          = ccpAdd(pointB, drawPoint);
        
        if (!isRight) {
            pointA.x    = pointA.x * -1;
            pointB.x    = pointB.x * -1;
        }
        
        if (self.holder.orientation == kOrientationLeft) {
            self.meleeImage.rotation = 20.;
        }else {
            self.meleeImage.rotation = -20.;
        }
        
        
        //draw the point
        [drawNode drawSegmentFrom:pointA to:pointB radius:3];
    }
}

-(void)applyb2ForceInRadius:(float)maxDistance withStrength:(float)str isOutwards:(BOOL)outwards aimedRight:(BOOL)right
{
    b2Vec2 b2ForcePosition = b2Vec2(drawNode.position.x/PTM_RATIO, drawNode.position.y/PTM_RATIO);
    
    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		b2Vec2 b2BodyPosition = b->GetPosition();
        
        //See if the body is close enough to apply a force
        float dist = b2Distance(b2ForcePosition, b2BodyPosition);
        
        //Dont apply forces behind the swing!
        BOOL shouldSwing;
        if (right) {
            if (b2ForcePosition.x > b2BodyPosition.x) {
                shouldSwing = NO;
            }else {
                shouldSwing = YES;
            }
        }else {
            if (b2ForcePosition.x > b2BodyPosition.x) {
                shouldSwing = YES;
            }else {
                shouldSwing = NO;
            }
        }
        if (dist > maxDistance || !shouldSwing) {
            //Too far away or wrong direction! Don't bother.
        }else {
            
            if (b->GetFixtureList()->GetFilterData().maskBits == MASK_BONES) {
                //Its part of a skeleton, set it to ragdoll for cool explosions
                GWCharacterAvatar *tempChar = ((__bridge GWCharacterAvatar *)b->GetUserData());
                tempChar.state = kStateRagdoll;
            }
            
            //Force is away from the center, calculate it and apply to the body
            //Dont have force diminish radially, since its a melee weapon
            float angle = atan2f(b2ForcePosition.y - b2BodyPosition.y, b2ForcePosition.x - b2BodyPosition.x);
            if (outwards) {
                angle = angle + M_PI;
            }
            // Apply an impulse to the body, using the angle
            b->ApplyLinearImpulse(b2Vec2(cosf(angle) * str, sinf(angle) * str), b2BodyPosition);
        }
	}
}

///Gesture Methods///

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (self.ammo >0) {        
        //Simulate trajectory;
        [self simulateMeleeWithStart:self.position Finger:currPoint];
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint) endPoint andTime:(float) time
{
    
}

-(void)handleTap:(CGPoint) tapPoint
{
    [drawNode clear];
    [self fireWeapon:tapPoint];
}

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

@end
