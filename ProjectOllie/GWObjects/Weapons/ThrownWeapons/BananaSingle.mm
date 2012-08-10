//
//  BananaSingle.m
//  ProjectOllie
//
//  Created by Lion User on 8/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BananaSingle.h"
#import "BananaGrenade.h"
#import "GameConstants.h"
#import "GWParticles.h"


@implementation BananaSingle

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(SINGLE_WIDTH*PTM_RATIO, SINGLE_HEIGHT*PTM_RATIO) imageName:SINGLE_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        
        
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
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:100 x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
        
        [self.gameWorld.camera addIntensity:1];
        
        [self applyb2ForceInRadius:150./PTM_RATIO withStrength:.02 isOutwards:YES];
        
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
