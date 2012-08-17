//
//  RailGunProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 8/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RailGunProjectile.h"
#import "RailGun.h"
#import "GWParticles.h"
#import "GameConstants.h"

@implementation RailGunProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(RAIL_B_WIDTH, RAIL_B_HEIGHT) imageName:RAIL_B_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        self.fuseTimer = 0;
        self.physicsBody->SetGravityScale(0);
        self.physicsBody->GetFixtureList()->SetDensity(3.);
        
        self.emitter = [GWParticleSoundCircle node];
        self.emitter.position = self.position;
        [self.gameWorld addChild:self.emitter];
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    self.emitter.position   = self.position;
    self.fuseTimer          += dt;
    if (self.fuseTimer >= 4. || self.bulletCollided) {
        [self destroyBullet];
    }
}

-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:200. x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
        
        [self applyb2ForceInRadius:350./PTM_RATIO withStrength:.05 isOutwards:YES];

        
        [self.emitter stopSystem];
        CCParticleSystem *newParticle = [GWParticleExplosion node];
        newParticle.position = self.position;
        [self.gameWorld addChild:newParticle];
        
    }
    [super destroyBullet];    
}


//This method is called by the contact listener, and should be overridden by any bullets inheriting from the 
//class (but not by thrown weapons, which will use a fuse time)
-(void)bulletContact
{
    self.bulletCollided = TRUE;
}

@end
