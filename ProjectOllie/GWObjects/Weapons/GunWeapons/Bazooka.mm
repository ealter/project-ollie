//
//  Bazooka.m
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Bazooka.h"
#import "BazookaProjectile.h"
#import "HMVectorNode.h"
#import "GameConstants.h"

@implementation Bazooka

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld
{
    if (self = [super initWithImage:BAZOOKA_IMAGE position:pos size:CGSizeMake(BAZOOKA_WIDTH, BAZOOKA_HEIGHT) ammo:ammo bulletSize:CGSizeMake(BAZOOKA_B_WIDTH, BAZOOKA_B_HEIGHT) bulletSpeed:.2 bulletImage:BAZOOKA_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Bazooka";
    self.description    = @"Fires a self-propelling rocket through the air.  Explodes on impact!";
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:aimPoint];
        
        //Make bullet
        BazookaProjectile *bullet= [[BazookaProjectile alloc] initWithStartPosition:CGPointMake(self.position.x + (cosf(self.wepAngle) * BAZOOKA_WIDTH*PTM_RATIO), self.position.y + (sinf(self.wepAngle) *BAZOOKA_WIDTH*PTM_RATIO)) b2World:_world gameWorld:self.gameWorld];
        bullet.physicsBody->SetTransform(bullet.physicsBody->GetPosition(), self.wepAngle);
        [self.gameWorld addChild:bullet];
        
        //NO FORCE APPLIED- BAZOOKA ACCELERATES AWAY. GIVE THE BULLET THE ACC VALUES
        bullet.accX = force.x;
        bullet.accY = force.y;
        
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
    CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), dt);
    stepGravity             = ccpMult(stepGravity, 0);
    CGPoint beginPoint      = drawNode.position;
    
    for (int i = 0; i < 20 ; i++) {
        CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * (i+i*i)*PTM_RATIO));
        
        //draw the point
        [drawNode drawDot:drawPoint radius:6];
    }
}

@end
