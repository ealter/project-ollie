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

-(id)initGunWithPosition:(CGPoint)pos ammo:(float)ammo box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initGunWithImage:GAUSS_IMAGE position:pos size:CGSizeMake(GAUSS_WIDTH, GAUSS_HEIGHT) ammo:ammo bulletSize:CGSizeMake(GAUSS_B_WIDTH, GAUSS_B_HEIGHT) bulletSpeed:.1 bulletImage:GAUSS_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
    }
        
    return self;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force, make bullet, apply force
        CGPoint force       = [self calculateGunVelocityWithAimPoint:aimPoint];
        GWProjectile *bullet= [[GaussRifleProjectile alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
        b2Body* bulletShape = bullet.physicsBody;
        float angle         = CC_RADIANS_TO_DEGREES(atan2f(self.position.y - aimPoint.y, self.position.x - aimPoint.x));
        angle               += 180;
        angle               = angle * -1;
        bullet.rotation     = angle;
        [self.parent addChild:bullet];
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
    CGPoint velocity        = [self calculateGunVelocityWithAimPoint:currPoint];
    velocity                = ccpMult(velocity, 10.);
    CGPoint stepVelocity    = ccpMult(velocity, dt);
    CGPoint gravPoint       = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
    CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), dt);
    CGPoint beginPoint      = ccpAdd(self.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
    
    for (int i = 0; i < 20 ; i++) {
        CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * (i+i*i)*PTM_RATIO));
        
        //draw the point
        [drawNode drawDot:drawPoint radius:6];
    }
}

@end
