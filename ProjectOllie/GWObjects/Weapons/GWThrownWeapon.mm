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


@implementation GWThrownWeapon
@synthesize thrownImage     = _thrownImage;
@synthesize animTimer       = _animTimer;
@synthesize animStarted     = _animStarted;
@synthesize releasePoint    = _releasePoint;

-(id)initWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo box2DWorld:(b2World *)world fuseTime:(float)fuseTime gameWorld:(ActionLayer *)gWorld
{
    if (self = [super init]) {
        //Set properties
        self.position       = ccpMult(pos, PTM_RATIO);
        self.contentSize    = CGSizeMake(size.width * PTM_RATIO, size.height * PTM_RATIO);
        self.ammo           = ammo;
        self.weaponImage    = imageName;
        fuseTimer           = fuseTime;
        countDown           = 0;
        _world              = world;
        self.gameWorld      = gWorld;    
        self.animStarted    = NO;
        self.animTimer      = 0;
        
        //Fill weapon descriptions
        [self fillDescription];
        //[self scheduleUpdate];

        //Set the drawnode color and location for trajectory simulation
        drawNode            = [HMVectorNode node];
        ccColor4F c         = ccc4f(.5f,.5f,0.f,.5f);
        [drawNode setColor:c];
        drawNode.position   = ccpAdd(drawNode.position, CGPointMake(self.contentSize.width/4, self.contentSize.height/4));
        
        //Set the image of the weapon, and its position
        self.thrownImage    = [CCSprite spriteWithFile:imageName];
        self.thrownImage.position= ccpAdd(self.thrownImage.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        
        //Add children
        [self addChild:self.thrownImage];
        [self addChild:drawNode];
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    if (self.animStarted) {
        self.animTimer += dt;
        if (self.animTimer > 0.8) {
            [self throwWeaponWithLocation:self.position fromFinger:self.releasePoint];
        }
    }
}

//Override this to throw a custom bullet!
-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    if (self.ammo >0) { 
        //Make a bullet which acts as the thrown item
        thrown              = [[GWProjectile alloc] initWithBulletSize:self.contentSize imageName:self.weaponImage startPosition:self.position b2World:_world b2Bullet:NO gameWorld:self.gameWorld];
        b2Body* thrownShape = thrown.physicsBody;
        thrown.fuseTimer    = fuseTimer;
        
        //Throw the weapon with calculated velocity
        thrownShape->SetTransform(thrownShape->GetPosition(), self.wepAngle);
        CGPoint vel         = [self calculateVelocityFromWep:self.holder.position toFinger:endPoint];
        thrownShape->SetLinearVelocity(b2Vec2(vel.x, vel.y));
        
        //Calculate some spin so throw looks better
        float throwSpin     = CCRANDOM_0_1();
        throwSpin = throwSpin/20000.;
        if (vel.x < 0) {
            throwSpin       = throwSpin * -1.;
        }
        thrownShape->ApplyAngularImpulse(throwSpin);
        
        [self.parent addChild:thrown];
        self.ammo--;
    }else {
        //no more ammo!
    }
}

//Calculate velocity using distance between character and finger.  set a max distance as well
-(CGPoint)calculateVelocityFromWep:(CGPoint) startPoint toFinger:(CGPoint) endPoint
{
    CGPoint vel;
    //Calculate distance and cap it
    float dist              = ccpDistance(startPoint, endPoint);
    if (dist > MAXTHROWNSPEED)dist= MAXTHROWNSPEED;
    dist                    = dist / 64;
    
    //Calculate angle and velocity
    float angle             = atan2f(startPoint.y-endPoint.y, startPoint.x - endPoint.x);
    self.wepAngle           = angle;
    vel                     = CGPointMake(cosf(angle)*dist, sinf(angle)*dist);
    return vel;
}

-(void)simulateTrajectoryWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint
{
    //Clear HMVectorNode
    [drawNode clear];
    
    //Calculate values to be used for trajectory simulation
    CGPoint beginPoint      = drawNode.position;
    float dt                = 1/60.0f;
    CGPoint velocity        = [self calculateVelocityFromWep:self.holder.position toFinger:currPoint];
    CGPoint stepVelocity    = ccpMult(velocity, dt);
    CGPoint gravPoint       = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
    CGPoint stepGravity     = ccpMult(ccpMult(gravPoint, dt), dt);
    self.flipY              = NO;
    
    //Simulate trajectory;
    for (int i = 0; i < 60 ; i++) {
        CGPoint drawPoint   = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * (i+i*i)*PTM_RATIO));
        
        //draw the point
        [drawNode drawDot:drawPoint radius:6];
    }
}

-(void)onEnter
{
    [self scheduleUpdate];
    self.animStarted = NO;
    [super onEnter];
}

-(void)onExit
{
    [self unscheduleUpdate];
    [super onExit];
}

//Gesture Methods//

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (self.ammo >0) {
        //Simulate trajectory
        [self simulateTrajectoryWithStart:self.position Finger:currPoint];
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint)endPoint andTime:(float)time
{
    [drawNode clear];
    self.animStarted = TRUE;
    self.animTimer      = 0;
    self.releasePoint = endPoint;
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
