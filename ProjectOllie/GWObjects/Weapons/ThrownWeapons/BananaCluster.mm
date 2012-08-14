//
//  BananaCluster.m
//  ProjectOllie
//
//  Created by Lion User on 8/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BananaCluster.h"
#import "BananaGrenade.h"
#import "BananaSingle.h"
#import "GameConstants.h"
#import "GWParticles.h"


@implementation BananaCluster

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(CLUSTER_WIDTH*PTM_RATIO, CLUSTER_HEIGHT*PTM_RATIO) imageName:CLUSTER_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        
        
    }
    
    return self;
}

-(void)update:(ccTime) dt
{
    destroyTimer += dt;
    if (destroyTimer > self.fuseTimer) {
        [self destroyBullet];
    }
    if (self.physicsBody->GetLinearVelocity().y < 0) {
        [self splitBananas];
        [super destroyBullet];
    }
}

-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:150 x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
        
        [self.gameWorld.camera addIntensity:.5];
        
        [self applyb2ForceInRadius:300./PTM_RATIO withStrength:.1 isOutwards:YES];
        
        self.emitter = [GWParticleExplosion node];
        self.emitter.position = self.position;
        [self.gameWorld addChild:self.emitter];
    }
    
    [super destroyBullet];
}

-(void)bulletContact
{
    
}

-(void)splitBananas
{
    b2Vec2 selfVel          = self.physicsBody->GetLinearVelocity();
    for (int i = 0; i < 5; i++) {
        //Make banana
        BananaSingle *single = [[BananaSingle alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
        single.fuseTimer = 2.;
        
        [self.gameWorld addChild:single];
        
        //Calculate new speeds and apply
        float angle         = atan2f(selfVel.y, selfVel.x);
        float changeX       = cosf(angle) * i / 100;
        float changeY       = sinf(angle) * i / 100;
        single.physicsBody->SetLinearVelocity(selfVel);
        single.physicsBody->ApplyForceToCenter(b2Vec2(changeX, changeY));
        
        //Calculate some spin so throw looks better
        float throwSpin = CCRANDOM_0_1();
        throwSpin = throwSpin/10000.;
        single.physicsBody->ApplyAngularImpulse(throwSpin);
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //Touch detected, split up the banana bunch into 3 bananas!
    [self splitBananas];    
    
    //Clean up self
    [[self gameWorld] removeChild:self.emitter cleanup:YES];
    [super destroyBullet];
    return YES;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

@end
