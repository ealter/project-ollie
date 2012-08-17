//
//  RailGun.m
//  ProjectOllie
//
//  Created by Lion User on 8/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RailGun.h"
#import "RailGunProjectile.h"
#import "HMVectorNode.h"
#import "GameConstants.h"

@implementation RailGun

-(id)initWithPosition:(CGPoint)pos ammo:(float)ammo box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:RAIL_IMAGE position:pos size:CGSizeMake(RAIL_WIDTH, RAIL_HEIGHT) ammo:ammo bulletSize:CGSizeMake(RAIL_B_WIDTH, RAIL_B_HEIGHT) bulletSpeed:.6 bulletImage:RAIL_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title  = @"Rail Gun";
    self.description = @"The rail gun is a frightening weapon that launches extremely unstable projectiles.  Point away from self.";
    self.type   = kType2HGun;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:aimPoint];
        
        //Make bullet
        RailGunProjectile *bullet= [[RailGunProjectile alloc] initWithStartPosition:CGPointMake(self.position.x + (cosf(self.wepAngle) * RAIL_WIDTH*PTM_RATIO), self.position.y + (sinf(self.wepAngle) *RAIL_WIDTH*PTM_RATIO)) b2World:_world gameWorld:self.gameWorld];
        b2Body* bulletShape = bullet.physicsBody;
        
        
        bullet.physicsBody->SetTransform(bullet.physicsBody->GetPosition(), self.wepAngle);
        [self.gameWorld addChild:bullet];
        
        
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
