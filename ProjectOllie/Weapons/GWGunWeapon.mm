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

@interface GWGunWeapon ()

@property (assign, nonatomic) CGSize gunSize;
@property (assign, nonatomic) CGSize bulletSize;
@property (strong, nonatomic) NSString *bulletImage;
@property (assign, nonatomic) float bulletSpeed;

@end

@implementation GWGunWeapon
@synthesize gunSize         = _gunSize;
@synthesize bulletSize      = _bulletSize;
@synthesize bulletImage     = _bulletImage;
@synthesize bulletSpeed     = _bulletSpeed;

- (id)initGunWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size bulletSize:(CGSize)bulletSize bulletSpeed:(float)bulletSpeed bulletImage:(NSString *)bulletImage box2DWorld:(b2World *)world
{
    if (self = [super init]) {
        self.weaponSprite   = [CCSprite spriteWithFile:imageName];
        self.position       = pos;
        self.gunSize        = size;
        self.bulletImage    = bulletImage;
        self.bulletSize     = bulletSize;
        self.bulletSpeed    = bulletSpeed;
        _world              = world;
        
        [self addChild:self.weaponSprite];
    }
    return self;
}

-(void)fireWeapon:(CGPoint)target
{
    GWBullet *bullet = [[GWBullet alloc] initWithBulletSize:self.bulletSize image:self.bulletImage startPosition:self.position target:target b2World:_world bulletSpeed:self.bulletSpeed];
    
    [self addChild:bullet];
    //Send the bullet towards the target
    CGPoint force = ccpMult(ccpSub(target, self.position), self.bulletSpeed);
    bullet.bulletSprite.physicsBody->ApplyForceToCenter(b2Vec2(force.x, -force.y));    
}

@end
