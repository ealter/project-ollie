//
//  Grenade_Projectile.m
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GrenadeProjectile.h"
#import "Box2D.h"
#import "Grenade.h"
#import "GameConstants.h"
#import "GWParticles.h"


@implementation GrenadeProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(GRENADE_WIDTH*PTM_RATIO, GRENADE_HEIGHT*PTM_RATIO) imageName:GRENADE_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        
        
    }
    
    return self;
}


-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:100 x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
        
        [self.gameWorld.camera addIntensity:1];
        
        [self applyb2ForceInRadius:150./PTM_RATIO withStrength:.02 isOutwards:YES];
        
        CCParticleSystem *emitter = [GWParticleExplosion node];
        emitter.position = self.position;
        [self.parent addChild:emitter];
    }
    
    [super destroyBullet];
}

-(void)bulletContact
{
    
}

@end
