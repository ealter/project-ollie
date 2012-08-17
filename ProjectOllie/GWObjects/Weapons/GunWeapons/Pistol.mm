//
//  Pistol.m
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Pistol.h"
#import "HMVectorNode.h"
#import "PistolProjectile.h"
#import "GameConstants.h"
#import "GWParticles.h"

@implementation Pistol


-(id)initWithPosition:(CGPoint)pos ammo:(float)ammo box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:PISTOL_IMAGE position:pos size:CGSizeMake(PISTOL_WIDTH, PISTOL_HEIGHT) ammo:ammo bulletSize:CGSizeMake(PISTOL_B_WIDTH, PISTOL_B_HEIGHT) bulletSpeed:.7 bulletImage:PISTOL_B_IMAGE box2DWorld:world gameWorld:gWorld]){
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Pistol";
    self.description    = @"A basic pistol. Load 'em up!";
    self.type   = kType1HGun;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.holder.position toAimPoint:aimPoint];
        
        //Make bullet
        PistolProjectile *bullet= [[PistolProjectile alloc] initWithStartPosition:CGPointMake(self.position.x + (cosf(self.wepAngle) * PISTOL_WIDTH*PTM_RATIO), self.position.y + (sinf(self.wepAngle) *PISTOL_WIDTH*PTM_RATIO)) b2World:_world gameWorld:self.gameWorld];
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
