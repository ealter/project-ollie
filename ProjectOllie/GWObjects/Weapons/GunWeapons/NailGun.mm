//
//  NailGun.m
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NailGun.h"
#import "HMVectorNode.h"
#import "NailGunProjectile.h"
#import "GameConstants.h"
#import "GWParticles.h"


@implementation NailGun

-(id)initWithPosition:(CGPoint)pos ammo:(float)ammo box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:NAILGUN_IMAGE position:pos size:CGSizeMake(NAILGUN_WIDTH, NAILGUN_HEIGHT) ammo:ammo bulletSize:CGSizeMake(NAILGUN_B_WIDTH, NAILGUN_B_HEIGHT) bulletSpeed:.7 bulletImage:NAILGUN_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Nail Gun";
    self.description    = @"Shoots nails.  Go happy gilmore on those apes!";
    self.type   = kType1HGun;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:aimPoint];
        
        //Make bullet
        NailGunProjectile *bullet= [[NailGunProjectile alloc] initWithStartPosition:CGPointMake(self.position.x + (cosf(self.wepAngle) * NAILGUN_WIDTH*PTM_RATIO), self.position.y + (sinf(self.wepAngle) *NAILGUN_WIDTH*PTM_RATIO)) b2World:_world gameWorld:self.gameWorld];
        //Muzzle flash code
        bullet.emitter          = [GWParticleMuzzleFlash node];
        bullet.emitter.position = bullet.position;
        bullet.emitter.gravity  = ccp(cosf(self.wepAngle)*3000, sinf(self.wepAngle)*3000);
        [bullet.gameWorld addChild:bullet.emitter];
        
        b2Body* bulletShape     = bullet.physicsBody;
        
        
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

@end
