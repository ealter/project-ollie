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
        
        self.emitter    = [GWParticleSpookyPurple node];
        
        //add children
        [self addChild:self.pill1];
        [self addChild:self.pill2];
        [self addChild:self.pill3];
        [self addChild:self.emitter];
        
        //set as sphere
        world->DestroyBody(self.physicsBody);
        b2BodyDef bd;
        b2CircleShape circle;
        b2FixtureDef fixtureDef;
        bd.type             = b2_dynamicBody;
        bd.linearDamping    = .1f;
        bd.angularDamping   = .1f;
        bd.bullet           = YES;//isBullet;
        circle.m_radius = self.contentSize.width/2./PTM_RATIO; 
        fixtureDef.shape    = &circle;
        fixtureDef.density  = 1.0f;
        fixtureDef.friction = 0.4f;
        fixtureDef.restitution = 0.1f;
        fixtureDef.filter.categoryBits = CATEGORY_PROJECTILES;
        fixtureDef.filter.maskBits = MASK_PROJECTILES;
        b2Body *bulletShape = _world->CreateBody(&bd);
        bulletShape->CreateFixture(&fixtureDef);
        bulletShape->SetTransform(b2Vec2(pos.x/PTM_RATIO,pos.y/PTM_RATIO), 0); 
        
        self.physicsBody = bulletShape;
        self.physicsBody->SetUserData((__bridge void*)self);
        bulletShape->SetTransform(b2Vec2(self.position.x/PTM_RATIO,self.position.y/PTM_RATIO), 0);   

    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    destroyTimer += dt;
    if (destroyTimer >= self.fuseTimer) {
        vortex = YES;
    }
    spin                += dt;
    self.pill1.rotation = spin*90;
    self.pill2.rotation = spin*180;
    self.pill3.rotation = spin*120;
    
    if (spin > 4) {
        spin =0;
    }
    self.emitter.position = self.position;
    
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
        
        [self.emitter stopSystem];
    }
    
    [super destroyBullet];
}

-(void)bulletContact
{
    
}


@end
