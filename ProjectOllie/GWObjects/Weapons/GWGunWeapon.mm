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
@property (assign, nonatomic) CGSize bulletSize;
@property (strong, nonatomic) NSString *bulletImage;
@property (assign, nonatomic) float bulletSpeed;

@end

@implementation GWGunWeapon
@synthesize bulletSize      = _bulletSize;
@synthesize bulletImage     = _bulletImage;
@synthesize bulletSpeed     = _bulletSpeed; 

- (id)initGunWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo bulletSize:(CGSize)bulletSize bulletSpeed:(float)bulletSpeed bulletImage:(NSString *)bulletImage box2DWorld:(b2World *)world
{
    if (self = [super initWithFile:imageName]) {
        self.position       = pos;
        self.contentSize    = size;
        self.ammo           = ammo;
        self.bulletImage    = bulletImage;
        self.bulletSize     = bulletSize;
        self.bulletSpeed    = bulletSpeed;
        _world              = world;
    }
    return self;
}

-(void)fireWeapon:(CGPoint)target
{
    if (self.ammo >0) {
        //Calculate force, make bullet, apply force
        CGPoint force = ccpMult(ccpMult(ccpSub(target, self.position), 1./ccpLength(ccpSub(target,self.position))),self.bulletSpeed);
        GWBullet *bullet = [[GWBullet alloc] initWithBulletSize:self.bulletSize imageName:self.bulletImage startPosition:self.position b2World:_world];
        b2Body* bulletShape = bullet.physicsBody;
        [self.parent addChild:bullet];
        bulletShape->ApplyLinearImpulse(b2Vec2(force.x, -force.y),bulletShape->GetPosition());
        
        
        self.ammo--;
    }else {
        //Out of ammo!
    }
}

@end
