//
//  BazookaProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BazookaProjectile.h"
#import "Bazooka.h"
#import "GWParticles.h"
#import "GameConstants.h"

@implementation BazookaProjectile
@synthesize accX        = _accX;
@synthesize accY        = _accY;

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(BAZOOKA_B_WIDTH, BAZOOKA_B_HEIGHT) imageName:BAZOOKA_B_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        self.physicsBody->SetGravityScale(0);
        bazookaTimer = 0;
        
        self.emitter = [GWParticleSmokeTrail node];
        self.emitter.position = self.position;
        [self.gameWorld addChild:self.emitter];
    }
    
    return self;
}

-(void)update:(ccTime)dt
{    
    bazookaTimer += dt;
    destroyTimer += dt;
    if (bazookaTimer < 2.) {
        self.physicsBody->ApplyForceToCenter(b2Vec2(self.accX/500, self.accY/500));
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
        
        [self.gameWorld.camera addIntensity:0.5];
        
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
