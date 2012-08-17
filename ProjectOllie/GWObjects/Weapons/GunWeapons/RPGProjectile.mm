//
//  RPGProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RPGProjectile.h"
#import "RPG.h"
#import "GWParticles.h"
#import "GameConstants.h"

@implementation RPGProjectile
@synthesize accX        = _accX;
@synthesize accY        = _accY;

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(RPG_B_WIDTH, RPG_B_HEIGHT) imageName:RPG_B_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        self.physicsBody->SetGravityScale(0.2);
        rpgTimer = 0;
        
        self.emitter = [GWParticleSmokeTrail node];
        self.emitter.position = self.position;
        [self.gameWorld addChild:self.emitter];
    }
    
    return self;
}

-(void)update:(ccTime)dt
{    
    rpgTimer += dt;
    destroyTimer += dt;
    if (rpgTimer < 1.5) {
        self.physicsBody->ApplyForceToCenter(b2Vec2(self.accX/350, self.accY/350));
    }
    self.emitter.position = self.position;
    if (self.bulletCollided || destroyTimer >= 4.) {
        [self destroyBullet];
    }
}

//YOU SHOULD OVERRIDE THIS OR AT LEAST CALL IT FROM THE CHILD!
-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:75. x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
        
        [self.gameWorld.gwCamera addIntensity:0.5];
        
        [self applyb2ForceInRadius:300./PTM_RATIO withStrength:.05 isOutwards:YES];
        
        
        CCParticleSystem* newEmitter = [GWParticleExplosion node];
        newEmitter.position = self.position;
        [self.gameWorld addChild:newEmitter];
    }
    
    //Clean up bullet and remove from parent
    
    [[self gameWorld] removeChild:self.emitter cleanup:YES];
    _world->DestroyBody(self.physicsBody);
    [[self parent] removeChild:self cleanup:YES];    
}


//This method is called by the contact listener, and should be overridden by any bullets inheriting from the 
//class (but not by thrown weapons, which will use a fuse time)
-(void)bulletContact
{
    self.bulletCollided = TRUE;
}

@end
