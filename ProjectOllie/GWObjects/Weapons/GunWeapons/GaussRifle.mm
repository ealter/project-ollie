//
//  GaussRifle.m
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GaussRifle.h"
#import "GaussRifleProjectile.h"
#import "HMVectorNode.h"
#import "GameConstants.h"

@implementation GaussRifle

-(id)initWithPosition:(CGPoint)pos ammo:(float)ammo box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:GAUSS_IMAGE position:pos size:CGSizeMake(GAUSS_WIDTH, GAUSS_HEIGHT) ammo:ammo bulletSize:CGSizeMake(GAUSS_B_WIDTH, GAUSS_B_HEIGHT) bulletSpeed:.2 bulletImage:GAUSS_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
        
    }
        
    return self;
}

-(void)fillDescription
{
    self.title = @"Gauss Rifle";
    self.description = @"The gauss rifle fires bullets that travel through terrain, directly towards your target.  Strike at the enemy from any angle with this drilling weapon.";
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:aimPoint];
        
        //Make bullet
        GaussRifleProjectile *bullet= [[GaussRifleProjectile alloc] initWithStartPosition:CGPointMake(self.position.x + (cosf(self.wepAngle) * GAUSS_WIDTH*PTM_RATIO), self.position.y + (sinf(self.wepAngle) *GAUSS_WIDTH*PTM_RATIO)) b2World:_world gameWorld:self.gameWorld];
        b2Body* bulletShape = bullet.physicsBody;
        
        
        bullet.physicsBody->SetTransform(bullet.physicsBody->GetPosition(), self.wepAngle);
        [self.gameWorld addChild:bullet];
        bullet.fireAngle = atan2f(force.y, force.x);
        
        
        //Apply force
        bulletShape->SetLinearVelocity(b2Vec2(force.x, force.y));
        
        [drawNode clear];
        self.ammo--;
    }else {
        //Out of ammo!
    }
}

-(void)simulateTrajectoryWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint
{
    //Clear HMVectorNode
    [drawNode clear];
    
    //Calculate values to be used for trajectory simulation
    float dt                = 1/60.0f;
    CGPoint velocity        = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:currPoint];
    velocity                = ccpMult(velocity, MAXSPEED);
    CGPoint stepVelocity    = ccpMult(velocity, dt);
    CGPoint gravPoint       = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
    CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), 0);
    CGPoint beginPoint      = drawNode.position;
    
    for (int i = 0; i < 20 ; i++) {
        CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * (i+i*i)*PTM_RATIO));
        
        //draw the point
        [drawNode drawDot:drawPoint radius:6];
    }
}

@end
