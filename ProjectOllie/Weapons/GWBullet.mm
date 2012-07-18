 //
//  GWBullet.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWBullet.h"
#import "GameConstants.h"
#import "Box2D.h"

@implementation GWBullet

-(id)initWithBulletSize:(CGSize)size image:(NSString *)imageName startPosition:(CGPoint)pos target:(CGPoint)target b2World:(b2World *)world bulletSpeed:(float)speed
{
    if ((self = [PhysicsSprite spriteWithFile:imageName])) {
        //take the world, speed, and pos
        _world              = world;
        [self setAnchorPoint:ccp(.5,.5)];
        //Box2D things
        b2BodyDef bd;
        b2PolygonShape box;
        b2FixtureDef fixtureDef;
        
        //Set up the BodyDef
        bd.type             = b2_dynamicBody;
        bd.linearDamping    = .1f;
        bd.angularDamping   = .1f;
       // bd.bullet           = YES;
        
        box.SetAsBox(.5, .5);
        
        fixtureDef.shape    = &box;
        fixtureDef.density  = 1.0f;
        fixtureDef.friction = 0.4f;
        fixtureDef.restitution = 0.1f;
        fixtureDef.filter.categoryBits = CATEGORY_PROJECTILES;
        fixtureDef.filter.maskBits = MASK_PROJECTILES;
        b2Body *bulletShape = _world->CreateBody(&bd);
        bulletShape->CreateFixture(&fixtureDef);
        b2Body *box2DBody = bulletShape;
        [self setPhysicsBody:box2DBody];

        [self setPosition:pos];
        self.physicsBody->SetTransform(b2Vec2(pos.x/PTM_RATIO,pos.y/PTM_RATIO), 0);
    }
    
    return self;
}

@end
