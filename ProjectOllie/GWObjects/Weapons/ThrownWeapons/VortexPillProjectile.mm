//
//  VortexPillProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "VortexPillProjectile.h"
#import "VortexPill.h"
#import "GameConstants.h"
#import "GWParticles.h"


@implementation VortexPillProjectile
@synthesize pill1       = _pill1;
@synthesize pill2       = _pill2;
@synthesize pill3       = _pill3;

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(VPILL_WIDTH*PTM_RATIO, VPILL_HEIGHT*PTM_RATIO) imageName:VPILL_IMAGE_1 startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        destroyTimer    = 0;
        vortex          = NO;
        hasClipped      = NO;
        
        //add extra sprites for PHAT effects
        self.pill1       = [CCSprite spriteWithFile:VPILL_IMAGE_2];
        self.pill1.position = ccp(VPILL_WIDTH*PTM_RATIO/2, VPILL_HEIGHT*PTM_RATIO/2);
        self.pill2       = [CCSprite spriteWithFile:VPILL_IMAGE_3];
        self.pill2.position = ccp(VPILL_WIDTH*PTM_RATIO/2, VPILL_HEIGHT*PTM_RATIO/2);
        self.pill3       = [CCSprite spriteWithFile:VPILL_IMAGE_4];
        self.pill3.position = ccp(VPILL_WIDTH*PTM_RATIO/2, VPILL_HEIGHT*PTM_RATIO/2);
        
        //add children
        [self addChild:self.pill1];
        [self addChild:self.pill2];
        [self addChild:self.pill3];
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    destroyTimer += dt;
    if (destroyTimer >= self.fuseTimer) {
        vortex = YES;
    }
    spin                += 1;
    self.pill1.rotation += spin;
    self.pill2.rotation += spin*2;
    self.pill3.rotation += spin*3;
    
    if (spin > 360) {
        spin -= 360;
    }
    
    if (vortex) {
        if (!hasClipped) {
            stayHere    = self.position;
            [self.gameWorld.gameTerrain clipCircle:NO WithRadius:250 x:self.position.x y:self.position.y];
            [self.gameWorld.gameTerrain shapeChanged];
            hasClipped  = YES;
        }
        [self applyb2ForceInRadius:250./PTM_RATIO withStrength:.08 isOutwards:NO];
        self.physicsBody->SetTransform(b2Vec2(stayHere.x/PTM_RATIO, stayHere.y/PTM_RATIO), 0);
        if (destroyTimer >= self.fuseTimer + .5) {
            [self destroyBullet];
        }
    }
}


-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world        
        [self.gameWorld.camera addIntensity:0.5];
        
        [self applyb2ForceInRadius:300./PTM_RATIO withStrength:.08 isOutwards:YES];
        self.physicsBody->SetTransform(b2Vec2(stayHere.x, stayHere.y), 0);
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
