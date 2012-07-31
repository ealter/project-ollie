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
#import "HMVectorNode.h"

#define MAXSPEED 15. //Maximum speed of the weapon's projectile

@interface GWGunWeapon ()
{
    HMVectorNode    *drawNode;
    CGPoint         rearPoint;//Used to track where the rotation was last set to
}
@property (assign, nonatomic) CGSize bulletSize;
@property (strong, nonatomic) NSString *bulletImage;
@property (assign, nonatomic) float bulletSpeed;
@property (strong, nonatomic) CCSprite *aimOverlay;
@property (strong, nonatomic) CCSprite *gunImage;
@end

@implementation GWGunWeapon
@synthesize bulletSize      = _bulletSize;
@synthesize bulletImage     = _bulletImage;
@synthesize bulletSpeed     = _bulletSpeed; 
@synthesize aimOverlay      = _aimOverlay;
@synthesize gunImage        = _gunImage;

- (id)initGunWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo bulletSize:(CGSize)bulletSize bulletSpeed:(float)bulletSpeed bulletImage:(NSString *)bulletImage box2DWorld:(b2World *)world
{
    if (self = [super init]) {
        self.position       = ccpMult(pos, PTM_RATIO);
        self.contentSize    = CGSizeMake(size.width * PTM_RATIO, size.height * PTM_RATIO);
        self.ammo           = ammo;
        self.bulletImage    = bulletImage;
        self.bulletSize     = CGSizeMake(bulletSize.width * PTM_RATIO, bulletSize.height * PTM_RATIO);
        self.bulletSpeed    = bulletSpeed;
        _world              = world;
        drawNode            = [HMVectorNode node];
        drawNode.position   = ccpSub(drawNode.position, self.position);
        ccColor4F c         = ccc4f(1.f,1.f,0.f,1.f);
        
        //Make the gun image and overlay image in the middle of the gun object, for easy rotation
        self.gunImage       = [CCSprite spriteWithFile:imageName];
        self.gunImage.position= ccpAdd(self.gunImage.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        
        //self.aimOverlay     = [CCSprite spriteWithFile:@"aimOverlay.png"];
        //self.aimOverlay     = ccpAdd(self.aimOverlay.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        //[self addChild:self.aimOverlay];
        [self addChild:self.gunImage];
        [self addChild:drawNode];    
        [drawNode setColor:c];
    }
    return self;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force, make bullet, apply force
        CGPoint force       = [self calculateGunVelocityWithAimPoint:aimPoint];
        GWBullet *bullet    = [[GWBullet alloc] initWithBulletSize:self.bulletSize imageName:self.bulletImage startPosition:self.position b2World:_world b2Bullet:YES];
        b2Body* bulletShape = bullet.physicsBody;
        [self.parent addChild:bullet];
        bulletShape->SetLinearVelocity(b2Vec2(force.x, force.y));
        
        [drawNode clear];
        self.ammo--;
    }else {
        //Out of ammo!
    }
}

-(CGPoint)calculateGunVelocityWithAimPoint:(CGPoint)aimPoint
{
    CGPoint vel;
    //Calculate velocity using gun's speed and the angle of the weapon.  set a max distance as well
    float dist                      = MAXSPEED * self.bulletSpeed;
    if (dist > MAXSPEED)        dist= MAXSPEED;   //ensures that max speed is capped
    float angle                     = atan2f(aimPoint.y - self.position.y, aimPoint.x - self.position.x);
    float vx                        = cosf(angle)*dist;
    float vy                        = sinf(angle)*dist;
    vel                             = CGPointMake(vx, vy);
    
    return vel;
}


///Gesture Methods///

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (ccpDistance(startPoint, self.position) < self.contentSize.width) {
        //Clear HMVectorNode
        [drawNode clear];
        
        //Calculate values to be used for trajectory simulation
        float dt                = 1/60.0f;
        CGPoint velocity        = [self calculateGunVelocityWithAimPoint:currPoint];
        CGPoint stepVelocity    = ccpMult(velocity, dt);
        CGPoint gravPoint       = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
        CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), dt);
        CGPoint beginPoint      = ccpAdd(self.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        
        //Rotate gun overlay
        float angle             = CC_RADIANS_TO_DEGREES(atan2f(self.position.y - currPoint.y, self.position.x - currPoint.x));
        angle += 180;
        angle = angle * -1;
        //self.aimOverlay.rotation= angle;
        self.gunImage.rotation = angle;
        
        //Simulate trajectory;
        for (int i = 0; i < 20 ; i++) {
            CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * i*i*PTM_RATIO));
            
            
            //Calculate alpha, and draw the point
            double alphaValue   = 1-(i/20);
            ccColor4F c         = ccc4f(1.f, 1.f, 0.f, alphaValue);
            [drawNode setColor:c];
            [drawNode drawDot:drawPoint radius:4];
        }
        rearPoint = currPoint;
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint) endPoint andTime:(float) time
{
    
}

-(void)handleTap:(CGPoint) tapPoint
{
    [self fireWeapon: rearPoint];
}

-(void)handleSwipeRightWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}

-(void)handleSwipeLeftWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}

-(void)handleSwipeUpWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}

-(void)handleSwipeDownWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity
{
    
}


@end