//
//  GWThrownWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWThrownWeapon.h"
#import "GameConstants.h"

@interface GWThrownWeapon()
{
    b2World *_world;
}
@end

@implementation GWThrownWeapon
@synthesize throwSprite       = _throwSprite;

-(id)initThrownWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size box2DWorld:(b2World *)world
{
    if (self = [super init]) {
        self.throwSprite = [PhysicsSprite spriteWithFile:imageName];
        self.position = pos;
        self.contentSize = size;
        _world = world;
        
    }
    
    return self;
}

-(void)throwWeapon:(float)angle withStrength:(float)strength
{
    //Make box2D body
    b2BodyDef bd;
    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    
    //Set up the BodyDef
    bd.type             = b2_dynamicBody;
    bd.gravityScale     = 1.;
    bd.linearDamping    = .1f;
    bd.angularDamping   = .1f;
    bd.bullet           = YES;
    
    box.SetAsBox(self.contentSize.width/PTM_RATIO, self.contentSize.height/PTM_RATIO);
    
    fixtureDef.shape    = &box;
    fixtureDef.density  = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    fixtureDef.filter.categoryBits = CATEGORY_PROJECTILES;
    fixtureDef.filter.maskBits = MASK_PROJECTILES;
    
    bd.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    b2Body *thrownShape = _world->CreateBody(&bd);
    thrownShape->CreateFixture(&fixtureDef);
    b2Body *box2DBody = thrownShape;
    
    [self.throwSprite setPhysicsBody:box2DBody];
    [self addChild:self.throwSprite];
    
    //Throw the weapon with given angle and force
    CGPoint force = ccpMult(ccpSub(target, self.position), self.bulletSpeed);
    self.throwSprite.physicsBody->ApplyLinearImpulse((b2Vec2(force.x, -force.y)), self.throwSprite.physicsBody->GetPosition()) ; 
}

@end
