//
//  FlaskChemical.m
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FlaskChemical.h"
#import "GameConstants.h"
#import "GWParticles.h"

#define CHEMICAL_WIDTH 5.
#define CHEMICAL_HEIGHT 2.
#define CHEMICAL_IMAGE @"fire.png"

@implementation FlaskChemical

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(CHEMICAL_WIDTH, CHEMICAL_HEIGHT) imageName:CHEMICAL_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        destroyTimer = 0;
        self.fuseTimer = 5.;
        tic = 0;
        meltHere = 0.;
        
        self.emitter = [GWParticleChemical node];
        [self.gameWorld addChild:self.emitter];
        self.emitter.position = self.position;
        
        //set as sphere
        world->DestroyBody(self.physicsBody);
        b2BodyDef bd;
        b2PolygonShape box;
        b2FixtureDef fixtureDef;
        
        box.SetAsBox(CHEMICAL_WIDTH/2./PTM_RATIO,CHEMICAL_HEIGHT/2./PTM_RATIO);

        bd.type             = b2_dynamicBody;
        bd.linearDamping    = .1f;
        bd.angularDamping   = .1f;
        bd.bullet           = YES;//isBullet;
        fixtureDef.shape    = &box;
        fixtureDef.density  = 1.0f;
        fixtureDef.friction = 0.4f;
        fixtureDef.restitution = 0.1f;
        fixtureDef.filter.categoryBits = CATEGORY_PELLETS;
        fixtureDef.filter.maskBits = MASK_PELLETS;
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
    self.emitter.position = self.position;
    if (meltHere != 0.) {
        self.position = CGPointMake(meltHere, self.position.y);
    }
    tic++;
    destroyTimer += dt;
    if (tic % 5 == 0) {
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:10 x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
    }
    if (destroyTimer >= self.fuseTimer) {
        [self destroyBullet];
    }
}

-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world                       
    }
    [self.emitter stopSystem];
    [super destroyBullet];
}

-(void)bulletContact
{
    meltHere = self.position.x;
}

@end
