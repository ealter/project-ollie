//
//  GWThrownWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWThrownWeapon.h"
#import "GameConstants.h"
#import "GWBullet.h"
#import "HMVectorNode.h"
#import "ccTypes.h"

@interface GWThrownWeapon()
{
    NSString *_imageName;
    HMVectorNode *drawNode;
}
@end

@implementation GWThrownWeapon

-(id)initThrownWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo box2DWorld:(b2World *)world
{
    if (self = [super initWithFile:imageName]) {
        _imageName          = imageName;
        self.position       = pos;
        self.contentSize    = size;
        self.ammo           = ammo;
        _world              = world;
        drawNode            = [HMVectorNode node];
        ccColor4F c         = ccc4f(1.f,0.f,0.f,1.f);
        drawNode.position   = ccpSub(drawNode.position, self.position);
        [drawNode setColor:c];
        [self addChild:drawNode];
        
    }
    
    return self;
}

-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    if (self.ammo >0) {
        //Make a bullet which acts as the thrown item
        GWBullet *thrown = [[GWBullet alloc] initWithBulletSize:self.contentSize imageName:_imageName startPosition:self.position b2World:_world];
        b2Body* thrownShape = thrown.physicsBody;
        [self.parent addChild:thrown];
        
        //Throw the weapon with given angle and force
        //CGPoint force = ccpMult(ccp(cosf(angle), sinf(angle)), strength);
        //thrownShape->ApplyLinearImpulse((b2Vec2(force.x, -force.y)), thrownShape->GetPosition()); 
        CGPoint vel = [self calculateVelocityFromWep:startPoint toFinger:endPoint];
        
        thrownShape->SetLinearVelocity(b2Vec2(vel.x, vel.y));
        self.ammo--;
    }else {
        //no more ammo!
        DebugLog(@"out of ammo!");
    }
}

-(CGPoint)calculateVelocityFromWep:(CGPoint) startPoint toFinger:(CGPoint) endPoint
{
    CGPoint vel;
    //Calculate velocity using distance between character and finger.  set a max distance as well
    float dist = ccpDistance(startPoint, endPoint);
    if (dist > 100) dist = 100;
    dist = dist /8;//Ensures that max speed is capped
    float angle = atan2f(startPoint.y-endPoint.y, startPoint.x - endPoint.x);
    float vx = cosf(angle)*dist;
    float vy = sinf(angle)*dist;
    vel = CGPointMake(vx, vy);
    
    return vel;
}

//Gesture Methods//

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (ccpDistance(startPoint, self.position) < self.contentSize.width) {

        [drawNode clear];
        float dt = 1/60.0f;
        CGPoint velocity = [self calculateVelocityFromWep:startPoint toFinger:currPoint];
        CGPoint stepVelocity = ccpMult(velocity, dt);
        CGPoint gravPoint = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
        CGPoint stepGravity = ccpMult(ccpMult(gravPoint, dt), dt);
        
        CGPoint beginPoint = ccpAdd(self.position, CGPointMake(self.contentSize.width/2, self.contentSize.height/2));
        //Simulate trajectory;
        for (int i = 0; i < 120 ; i++) {
            CGPoint drawPoint = ccpAdd(ccpAdd(beginPoint, ccpMult(stepVelocity, i*PTM_RATIO)), ccpMult(stepGravity, 0.5f * i*i*PTM_RATIO));
            //Calculate alpha, and draw the point
            double alphaValue   = MIN(1, 45/i);
            ccColor4F c = ccc4f(1.f, .1f, 0.f, alphaValue);
            [drawNode setColor:c];
            [drawNode drawDot:drawPoint radius:2];
        }
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint)endPoint andTime:(float)time
{
    [drawNode clear];
    if (ccpDistance(startPoint, self.position) < self.contentSize.width) {
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
