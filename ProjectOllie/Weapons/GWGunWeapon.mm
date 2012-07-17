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
//Gun Size
@property (assign, nonatomic) CGSize gunSize;

//Bullet Size
@property (assign, nonatomic) CGSize bulletSize;

//Bullet Image
@property (strong, nonatomic) NSString *bulletImage;

//Bullet Speed
@property (assign, nonatomic) float bulletSpeed;

@end

@implementation GWGunWeapon
@synthesize gunSize         = _gunSize;
@synthesize bulletSize      = _bulletSize;
@synthesize bulletImage     = _bulletImage;
@synthesize bulletSpeed     = _bulletSpeed;

-(id)initGunWithImage:(NSString *)imageName andPosition:(CGPoint)pos andSize:(CGSize)size bulletSize:(CGSize)bSize bulletSpeed:(float)bSpeed bulletImage:(NSString *)bImage box2DWorld:(b2World *)world
{
    if (self = [super init]) {
        self.weaponSprite   = [CCSprite spriteWithFile:imageName];
        self.position       = pos;
        self.gunSize        = size;
        self.bulletImage    = bImage;
        self.bulletSize     = bSize;
        self.bulletSpeed    = bSpeed;
        _world              = world;
        
        [self addChild:self.weaponSprite];
    }
    
    return self;
}


-(void)fireWeapon:(CGPoint)target
{
    
    GWBullet * bullet = [[GWBullet alloc]initWithBulletSize:self.bulletSize andImage:self.bulletImage andStartPosition:self.position andTarget:target b2World:_world bulletSpeed:self.bulletSpeed];
    
    [self addChild:bullet];
    //Send the bullet towards the target
    float forceX = (target.x - self.position.x)*self.bulletSpeed;
    float forceY = (target.y - self.position.y)*self.bulletSpeed;
    bullet.bulletSprite.physicsBody->ApplyForceToCenter(b2Vec2(forceX, -forceY));    
}

@end
