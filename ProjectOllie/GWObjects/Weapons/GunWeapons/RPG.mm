//
//  RPG.m
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RPG.h"
#import "RPGProjectile.h"
#import "HMVectorNode.h"
#import "GameConstants.h"


@implementation RPG

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld
{
    if (self = [super initWithImage:RPG_IMAGE position:pos size:CGSizeMake(RPG_WIDTH, RPG_HEIGHT) ammo:ammo bulletSize:CGSizeMake(RPG_B_WIDTH, RPG_B_HEIGHT) bulletSpeed:.2 bulletImage:RPG_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"RPG";
    self.description    = @"Fires a self-propelling grenade.  Explodes on impact!";
    self.type   = kType2HGun;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:aimPoint];
        
        //Make bullet
        RPGProjectile *bullet= [[RPGProjectile alloc] initWithStartPosition:CGPointMake(self.position.x + (cosf(self.wepAngle) * RPG_WIDTH*PTM_RATIO), self.position.y + (sinf(self.wepAngle) *RPG_WIDTH*PTM_RATIO)) b2World:_world gameWorld:self.gameWorld];
        bullet.physicsBody->SetTransform(bullet.physicsBody->GetPosition(), self.wepAngle);
        [self.gameWorld addChild:bullet];
        
        //NO FORCE APPLIED- RPG ACCELERATES AWAY. GIVE THE BULLET THE ACC VALUES
        bullet.accX = force.x;
        bullet.accY = force.y;
        
        [drawNode clear];
        self.ammo--;
    }else {
        //Out of ammo!
    }
}

@end
