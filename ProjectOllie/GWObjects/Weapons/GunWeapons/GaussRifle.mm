//
//  GaussRifle.m
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GaussRifle.h"
#import "GaussRifleProjectile.h"


@implementation GaussRifle

-(id)initWithPosition:(CGPoint)pos ammo:(float)ammo box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:GAUSS_IMAGE position:pos size:CGSizeMake(GAUSS_WIDTH, GAUSS_HEIGHT) ammo:ammo bulletSize:CGSizeMake(GAUSS_B_WIDTH, GAUSS_B_HEIGHT) bulletSpeed:.15 bulletImage:GAUSS_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
    }
        
    return self;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.position toAimPoint:aimPoint];
        
        //Make bullet
        GaussRifleProjectile *bullet= [[GaussRifleProjectile alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
        b2Body* bulletShape = bullet.physicsBody;
        bullet.physicsBody->SetTransform(bullet.physicsBody->GetPosition(), self.wepAngle);
        [self.parent addChild:bullet];
        
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
    CGPoint velocity        = [self calculateGunVelocityFromStart:self.position toAimPoint:currPoint];
    velocity                = ccpMult(velocity, MAXSPEED);
    CGPoint stepVelocity    = ccpMult(velocity, dt);
    CGPoint gravPoint       = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
    CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), 0);
    CGPoint beginPoint      = ccpAdd(self.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
    
    for (int i = 0; i < 20 ; i++) {
        CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * (i+i*i)*PTM_RATIO));
        
        //draw the point
        [drawNode drawDot:drawPoint radius:6];
    }
}

@end
