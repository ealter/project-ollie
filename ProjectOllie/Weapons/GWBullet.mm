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
@synthesize bulletSpeed     = _bulletSpeed;
@synthesize bulletSize      = _bulletSize;
@synthesize bulletSprite    = _bulletSprite;

-(id)initWithBulletSize:(CGSize)size andImage:(NSString *)imageName andStartPosition:(CGPoint)pos andTarget:(CGPoint)target b2World:(b2World *)world bulletSpeed:(float)speed
{
    if (self = [super init]) {
        //take the world, speed, and pos
        _world              = world;
        self.bulletSpeed    = speed;
        self.position       = pos;
        self.contentSize    = size;
        
        //set bullet size and sprite
        self.bulletSize     = size;
        self.bulletSprite   = [PhysicsSprite spriteWithFile:imageName];
        self.bulletSprite.position = ccp(pos.x, pos.y);
        
        //Box2D things
        b2BodyDef bd;
        b2PolygonShape box;
        b2FixtureDef fixtureDef;
        
        //Set up the BodyDef
        bd.type             = b2_dynamicBody;
        bd.gravityScale     = 1.;
        bd.linearDamping    = .1f;
        bd.angularDamping   = .1f;
        bd.bullet           = YES;
        
        box.SetAsBox(self.bulletSize.width/PTM_RATIO, self.bulletSize.height/PTM_RATIO);
        
        fixtureDef.shape    = &box;
        fixtureDef.density  = 1.0f;
        fixtureDef.friction = 0.4f;
        fixtureDef.restitution = 0.1f;
        fixtureDef.filter.categoryBits = CATEGORY_PROJECTILES;
        fixtureDef.filter.maskBits = MASK_PROJECTILES;
        
        bd.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
        b2Body *bulletShape = _world->CreateBody(&bd);
        bulletShape->CreateFixture(&fixtureDef);
        b2Body *box2DBody = bulletShape;

        [self.bulletSprite setPhysicsBody:box2DBody];
        [self addChild:self.bulletSprite];
    }
    
    return self;
}

@end
