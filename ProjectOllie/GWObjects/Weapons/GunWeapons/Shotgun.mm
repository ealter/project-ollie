//
//  Shotgun.m
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Shotgun.h"
#import "ShotgunProjectile.h"
#import "HMVectorNode.h"
#include "GameConstants.h"

@implementation Shotgun

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld
{
    if (self = [super initWithImage:SHOTGUN_IMAGE position:pos size:CGSizeMake(SHOTGUN_WIDTH, SHOTGUN_HEIGHT) ammo:ammo bulletSize:CGSizeMake(SHOTGUN_B_WIDTH, SHOTGUN_B_HEIGHT) bulletSpeed:.3 bulletImage:SHOTGUN_B_IMAGE box2DWorld:world gameWorld:gWorld]) {
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Shotgun";
    self.description    = @"Basic shotgun.  Fires a cone of pellets that hurt more the closer they are!";
    self.type   = kType2HGun;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint velocity            = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:aimPoint];
        
        for (int i = -(NUM_PELLETS/2); i<(NUM_PELLETS/2); i++) {
            //Make Bullet
            ShotgunProjectile *bullet   = [[ShotgunProjectile alloc] initWithStartPosition:CGPointMake(self.position.x + (cosf(self.wepAngle) * SHOTGUN_WIDTH*PTM_RATIO), self.position.y + (sinf(self.wepAngle) *SHOTGUN_WIDTH*PTM_RATIO)) b2World:_world gameWorld:self.gameWorld];
            b2Body* bulletShape = bullet.physicsBody;
            [self.gameWorld addChild:bullet];
            
            bullet.physicsBody->SetGravityScale(0.);
            
            //Fan out the bullets in a cone
            float changeX               = sinf(self.wepAngle) * i / NUM_PELLETS / (10 * NUM_PELLETS);
            float changeY               = cosf(self.wepAngle) * i / NUM_PELLETS / (10 * NUM_PELLETS);
            
                        
            //Apply the force
            bulletShape->SetLinearVelocity(b2Vec2(velocity.x, velocity.y));
            bulletShape->ApplyForceToCenter(b2Vec2(changeX, changeY));
        }
        
        [drawNode clear];
        self.ammo--;
    }else {
        //Out of ammo!
    }
}


@end
