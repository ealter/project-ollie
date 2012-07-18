//
//  GWGunWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWGunWeapon.h"
#import "Box2D.h"
#import "cocos2d.h"
#import "GWBullet.h"
#import "GameConstants.h"

@interface GWGunWeapon ()
{

}
@property (assign, nonatomic) CGSize gunSize;
@property (assign, nonatomic) CGSize bulletSize;
@property (strong, nonatomic) NSString *bulletImage;
@property (assign, nonatomic) float bulletSpeed;
@property (strong, nonatomic) CCNode* bulletParent;
@end

@implementation GWGunWeapon
@synthesize gunSize         = _gunSize;
@synthesize bulletSize      = _bulletSize;
@synthesize bulletImage     = _bulletImage;
@synthesize bulletSpeed     = _bulletSpeed;
@synthesize bulletParent    = _bulletParent;

- (id)initGunWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size bulletSize:(CGSize)bulletSize bulletSpeed:(float)bulletSpeed bulletImage:(NSString *)bulletImage box2DWorld:(b2World *)world bulletParent:(CCNode*)parent;
{
    if (self = [super initWithFile:imageName]) {
        self.position       = pos;
        self.gunSize        = size;
        self.bulletImage    = bulletImage;
        self.bulletSize     = bulletSize;
        self.bulletSpeed    = bulletSpeed;
        _world              = world;
        self.bulletParent   = parent;
    }
    return self;
}

-(void)fireWeapon:(CGPoint)target
{
    /*
    GWBullet *bullet = [[GWBullet alloc] initWithBulletSize:self.bulletSize image:self.bulletImage startPosition:self.position target:target b2World:_world bulletSpeed:self.bulletSpeed];
    
    [self.parent addChild:bullet];
    //Send the bullet towards the target
   
    bullet.physicsBody->ApplyLinearImpulse(b2Vec2(0, 0),bullet.physicsBody->GetPosition());    */
    CGPoint force = ccpMult(ccpSub(target, self.position), self.bulletSpeed);
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
    bulletShape->SetTransform(b2Vec2(target.x/PTM_RATIO,target.y/PTM_RATIO), 0);
    bulletShape->ApplyLinearImpulse(b2Vec2(force.x, -force.y),bulletShape->GetPosition());
}

@end
