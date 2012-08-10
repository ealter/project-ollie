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
}

-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:150 x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
        
        [self.gameWorld.camera addIntensity:1];
        
        [self applyb2ForceInRadius:150./PTM_RATIO withStrength:.03 isOutwards:YES];
        
        self.emitter = [GWParticleExplosion node];
        self.emitter.position = self.position;
        [self.gameWorld addChild:self.emitter];
    }
    
    [super destroyBullet];
}

-(void)bulletContact
{
    
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //Touch detected, split up the banana bunch into 3 bananas!
    b2Vec2 selfVel          = self.physicsBody->GetLinearVelocity();
    CGPoint selfVelocity    = CGPointMake(selfVel.x, selfVel.y);
    for (int i = 0; i < 3; i++) {
        BananaSingle *single = [[BananaSingle alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
        [self.gameWorld addChild:single];
        CGPoint tempVel    = ccpAdd(selfVelocity, CGPointMake(0, 0));
        single.physicsBody->SetLinearVelocity(b2Vec2(tempVel.x, tempVel.y));
    }
    
    
    //Clean up self
    [[self gameWorld] removeChild:self.emitter cleanup:YES];
    [super destroyBullet];
    return YES;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

@end
