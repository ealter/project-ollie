//
//  GWGunWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWGunWeapon.h"
#import "Box2D.h"
#import "cocos2d.h"
#import "GWProjectile.h"
#import "GameConstants.h"
#import "HMVectorNode.h"


@interface GWGunWeapon ()

@end

@implementation GWGunWeapon
@synthesize bulletSize      = _bulletSize;
@synthesize bulletImage     = _bulletImage;
@synthesize bulletSpeed     = _bulletSpeed; 
@synthesize aimOverlay      = _aimOverlay;
@synthesize gunImage        = _gunImage;

- (id)initWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo bulletSize:(CGSize)bulletSize bulletSpeed:(float)bulletSpeed bulletImage:(NSString *)bulletImage box2DWorld:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super init]) {
        self.position       = ccpMult(pos, PTM_RATIO);
        self.contentSize    = CGSizeMake(size.width * PTM_RATIO, size.height * PTM_RATIO);
        self.ammo           = ammo;
        self.bulletImage    = bulletImage;
        self.bulletSize     = CGSizeMake(bulletSize.width * PTM_RATIO, bulletSize.height * PTM_RATIO);
        self.bulletSpeed    = bulletSpeed;
        _world              = world;
        self.gameWorld      = gWorld;
        drawNode            = [HMVectorNode node];
        drawNode.position   = ccpAdd(drawNode.position, CGPointMake(self.contentSize.width/4, self.contentSize.height/4));
        ccColor4F c         = ccc4f(.5f,.5f,0.f,.5f);
        
        //Make the gun image and overlay image in the middle of the gun object, for easy rotation
        self.gunImage       = [CCSprite spriteWithFile:imageName];
        self.gunImage.position= ccpAdd(self.gunImage.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        self.gunImage.flipX = NO;
        
        self.aimOverlay     = [CCSprite spriteWithFile:@"aimOverlay.png"];
        self.aimOverlay.position     = ccpAdd(self.aimOverlay.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        self.aimOverlay.flipX = YES;
        [self addChild:self.aimOverlay];
        [self addChild:self.gunImage];
        [self addChild:drawNode];    
        [drawNode setColor:c];
        shootPoint = CGPointMake(0, 0);
    }
    return self;
}


-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {
        //Calculate force
        CGPoint force       = [self calculateGunVelocityFromStart:self.position toAimPoint:aimPoint];
        
        //Make bullet
        GWProjectile *bullet    = [[GWProjectile alloc] initWithBulletSize:self.bulletSize imageName:self.bulletImage startPosition:self.position b2World:_world b2Bullet:YES gameWorld:self.gameWorld];
        b2Body* bulletShape = bullet.physicsBody;
        bullet.physicsBody->SetTransform(bullet.physicsBody->GetPosition(), self.wepAngle);
        [self.parent addChild:bullet];
        
        //Apply force
        bulletShape->SetLinearVelocity(b2Vec2(force.x, force.y));
        
        //Clear drawNode, decrement ammo
        [drawNode clear];
        self.ammo--;
    }else {
        //Out of ammo!
    }
}

-(CGPoint)calculateGunVelocityFromStart:(CGPoint) startPoint toAimPoint:(CGPoint) aimPoint
{
    CGPoint vel;
    //Calculate velocity using gun's speed and the angle of the weapon.  set a max distance as well
    float dist                      = MAXSPEED * self.bulletSpeed;
    if (dist > MAXSPEED)        dist= MAXSPEED;   //ensures that max speed is capped
    float angle                     = atan2f(aimPoint.y - startPoint.y, aimPoint.x - startPoint.x);
    self.wepAngle                   = angle;
    float vx                        = cosf(angle)*dist;
    float vy                        = sinf(angle)*dist;
    vel                             = CGPointMake(vx, vy);
    
    return vel;
}

-(void)simulateTrajectoryWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint
{
    //Clear HMVectorNode
    [drawNode clear];
    
    //Calculate values to be used for trajectory simulation
    float dt                = 1/60.0f;
    CGPoint velocity        = [self calculateGunVelocityFromStart:self.position toAimPoint:currPoint];
    CGPoint stepVelocity    = ccpMult(velocity, dt);
    CGPoint gravPoint       = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
    CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), dt);
    CGPoint beginPoint      = drawNode.position;
    
    for (int i = 0; i < 20 ; i++) {
        CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * (i+i*i)*PTM_RATIO));
        
        //draw the point
        [drawNode drawDot:drawPoint radius:6];
    }
}

///Gesture Methods///

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (ccpDistance(startPoint, self.position) < self.contentSize.width && self.ammo >0) {
        //Rotate gun overlay
        float angle             = CC_RADIANS_TO_DEGREES(self.wepAngle);
        if (abs(angle) > 90) {
            self.gunImage.flipY = NO;
        }else {
            self.gunImage.flipY = YES;
        }
        angle += 180;
        angle = angle * -1;
        self.aimOverlay.rotation= angle;
        self.gunImage.rotation = angle;
        
        
        //Simulate trajectory;
        [self simulateTrajectoryWithStart:startPoint Finger:currPoint];
        
        shootPoint = currPoint;
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint) endPoint andTime:(float) time
{
    
}

-(void)handleTap:(CGPoint) tapPoint
{
    if (shootPoint.x != 0 && shootPoint.y != 0) {
        [self fireWeapon:shootPoint];
    }
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
