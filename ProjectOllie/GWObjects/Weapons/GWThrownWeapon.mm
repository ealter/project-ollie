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

@interface GWThrownWeapon()
{
    NSString *_imageName;
    HMVectorNode *drawNode;
}
@end

@implementation GWThrownWeapon

-(id)initThrownWithImage:(NSString *)imageName position:(CGPoint)pos size:(CGSize)size ammo:(float) ammo box2DWorld:(b2World *)world
{
    if (self = [super init]) {
        _imageName          = imageName;
        self.position       = pos;
        self.contentSize    = size;
        self.ammo           = ammo;
        _world              = world;
        drawNode            = [HMVectorNode node];
        [self addChild:drawNode];
        
    }
    
    return self;
}

-(void)throwWeaponWithAngle:(float)angle withStrength:(float)strength
{
    if (self.ammo >0) {
        //Make a bullet which acts as the thrown item
        GWBullet *thrown = [[GWBullet alloc] initWithBulletSize:self.contentSize imageName:_imageName startPosition:self.position b2World:_world];
        b2Body* thrownShape = thrown.physicsBody;
        [self.parent addChild:thrown];
        
        //Throw the weapon with given angle and force
        CGPoint force = ccpMult(ccp(cosf(angle), sinf(angle)), strength);
        thrownShape->ApplyLinearImpulse((b2Vec2(force.x, -force.y)), thrownShape->GetPosition()) ; 
        
        self.ammo--;
    }else {
        //no more ammo!
    }
}

-(CGPoint)calculateVelocityFromWep:(CGPoint) startPoint toFinger:(CGPoint) endPoint
{
    CGPoint vel;
    //Calculate velocity using distance between character and finger.  set a max distance as well
    float dist = ccpDistance(startPoint, endPoint);
    if (dist > 30) dist = 30;
    dist = dist /2;//Ensures that max speed is 15 m/s
    float angle = atan2f(startPoint.y-endPoint.y, startPoint.x - endPoint.x);
    float vx = cosf(angle)*dist;
    float vy = sinf(angle)*dist;
    vel = CGPointMake(vx, vy);
    
    return vel;
}

//Gesture Methods//

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time
{
    if (ccpDistance(startPoint, self.position) < 10) {
        [drawNode clear];
        
        float dt = 1/60;
        CGPoint velocity = [self calculateVelocityFromWep:startPoint toFinger:currPoint];
        CGPoint stepVelocity = ccpMult(velocity, dt);
        CGPoint gravPoint = CGPointMake(_world->GetGravity().x, _world->GetGravity().y);
        CGPoint stepGravity = ccpMult(ccpMult(gravPoint, dt), dt);
        
        //Simulate 1 second of trajectory;
        for (int i = 0; i < 60 ; i++) {
            CGPoint drawPoint = ccpAdd(ccpAdd(startPoint, ccpMult(stepGravity, 0.5f * (i*i+i))), ccpMult(stepVelocity, i));
            ccDrawPoint(drawPoint);
            [drawNode drawDot:drawPoint radius:1];
        }
    }
}

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint)endPoint andTime:(float)time
{
    [drawNode clear];
    
    if (ccpDistance(startPoint, self.position) < 10) {
        float angle = atan2f(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
        [self throwWeaponWithAngle:angle withStrength:ccpDistance(startPoint, endPoint)];
    }
}

@end
