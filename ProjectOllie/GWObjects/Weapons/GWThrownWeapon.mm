//
//  GWThrownWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWThrownWeapon.h"
#import "GameConstants.h"
#import "ccTypes.h"

#define MAXSPEED 160. //Max speed of the weapon's projectile


@implementation GWThrownWeapon

-(id)initWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo box2DWorld:(b2World *)world fuseTime:(float)fuseTime gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithFile:imageName]) {
        _imageName          = imageName;
        self.position       = ccpMult(pos, PTM_RATIO);
        self.contentSize    = CGSizeMake(size.width * PTM_RATIO, size.height * PTM_RATIO);
        self.ammo           = ammo;
        fuseTimer           = fuseTime;
        countDown           = 0;
        _world              = world;
        drawNode            = [HMVectorNode node];
        ccColor4F c         = ccc4f(.5f,.5f,0.f,.5f);
        drawNode.position   = ccpAdd(drawNode.position, CGPointMake(self.contentSize.width/4, self.contentSize.height/4));
        self.gameWorld      = gWorld;
        self.flipX          = NO;
        [self scheduleUpdate];
        [drawNode setColor:c];
        [self addChild:drawNode];
    }
    
    return self;
}


//Override this to throw a custom bullet!
-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    if (self.ammo >0) {
        //Make a bullet which acts as the thrown item
        thrown              = [[GWProjectile alloc] initWithBulletSize:self.contentSize imageName:_imageName startPosition:self.position b2World:_world b2Bullet:NO gameWorld:self.gameWorld];
        b2Body* thrownShape = thrown.physicsBody;
        [self.parent addChild:thrown];
        
        //Throw the weapon with calculated velocity
        CGPoint vel         = [self calculateVelocityFromWep:self.holder.position toFinger:endPoint];
        thrownShape->SetLinearVelocity(b2Vec2(vel.x, vel.y));
        
        //Calculate some spin so throw looks better
        float throwSpin = CCRANDOM_0_1();
        throwSpin = throwSpin/20000.;
        if (vel.x < 0) {
            throwSpin = throwSpin * -1.;
        }
        thrownShape->ApplyAngularImpulse(throwSpin);
        
        self.ammo--;
    }else {
        //no more ammo!
    }
}

-(CGPoint)calculateVelocityFromWep:(CGPoint) startPoint toFinger:(CGPoint) endPoint
{
    CGPoint vel;
    //Calculate velocity using distance between character and finger.  set a max distance as well
    float dist              = ccpDistance(startPoint, endPoint);
    if (dist > MAXSPEED)dist= MAXSPEED;
    dist                    = dist / 64;
    float angle             = atan2f(startPoint.y-endPoint.y, startPoint.x - endPoint.x);
    self.wepAngle           = angle;
    float vx                = cosf(angle)*dist;
    float vy                = sinf(angle)*dist;
    vel                     = CGPointMake(vx, vy);
    
    return vel;
}

- (void)update:(ccTime)dt {
    if (thrown != NULL) {
        self.visible = NO;
        countDown += dt;
        if (countDown > fuseTimer) {
            [thrown destroyBullet];
            thrown = NULL;
            countDown = 0;
            self.visible = YES;
        }
    }    
}

//Gesture Methods//

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (thrown == NULL && self.ammo >0) {
        //Clear HMVectorNode
        [drawNode clear];
        
        //Calculate values to be used for trajectory simulation
        CGPoint beginPoint      = drawNode.position;
        float dt                = 1/60.0f;
        CGPoint velocity        = [self calculateVelocityFromWep:self.holder.position toFinger:currPoint];
        CGPoint stepVelocity    = ccpMult(velocity, dt);
        CGPoint gravPoint       = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
        CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), dt);
        
        //flip da weapon.
        float angle             = CC_RADIANS_TO_DEGREES(self.wepAngle);
        if (abs(angle) > 90) {
            self.flipY = NO;
        }else {
            self.flipY = YES;
        }
        
        //Simulate trajectory;
        for (int i = 0; i < 60 ; i++) {
            CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * (i+i*i)*PTM_RATIO));
            
            //draw the point
            [drawNode drawDot:drawPoint radius:6];
        }
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint)endPoint andTime:(float)time
{
    [drawNode clear];
    if (thrown == NULL) {
        [self throwWeaponWithLocation:startPoint fromFinger:endPoint];
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

-(void)handleTap:(CGPoint) tapPoint
{
    
}

@end
