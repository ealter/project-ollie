//
//  Grenade_Projectile.m
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GrenadeProjectile.h"
#import "Grenade.h"
#import "GameConstants.h"
#import "GWParticles.h"

@implementation GrenadeProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(GRENADE_WIDTH*PTM_RATIO, GRENADE_HEIGHT*PTM_RATIO) imageName:GRENADE_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        destroyTimer = 0;
        
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    destroyTimer += dt;
    if (destroyTimer >= self.fuseTimer) {
        [self destroyBullet];
    }
}

-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:100 x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
        
        [self.gameWorld.camera addIntensity:1];
        
        [self applyb2ForceInRadius:300./PTM_RATIO withStrength:.08 isOutwards:YES];
        
        self.emitter = [GWParticleExplosion node];
        self.emitter.position = self.position;
        [self.gameWorld addChild:self.emitter];
    }
    
    [super destroyBullet];
}

-(void)bulletContact
{
    
}

@end
