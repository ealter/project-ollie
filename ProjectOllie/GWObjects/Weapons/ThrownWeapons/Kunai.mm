//
//  Kunai.m
//  ProjectOllie
//
//  Created by Lion User on 8/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Kunai.h"
#import "GameConstants.h"
#import "KunaiProjectile.h"


@implementation Kunai

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:KUNAI_IMAGE position:pos size:CGSizeMake(KUNAI_WIDTH, KUNAI_HEIGHT) ammo:ammo box2DWorld:world fuseTime:4 gameWorld:gWorld]) {
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Kunai";
    self.description    = @"Small throwing dagger.  Good for hurting the enemies.";
    self.type   = kTypeThrown;
}


-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    if (self.ammo >0) {
        //Make a bullet which acts as the thrown item
        thrown              = [[KunaiProjectile alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
        b2Body* thrownShape = thrown.physicsBody;
        [self.gameWorld addChild:thrown];
        thrown.fuseTimer    = fuseTimer;
        thrownShape->SetTransform(thrownShape->GetPosition(), self.wepAngle);

        
        //Throw the weapon with calculated velocity
        CGPoint vel         = [self calculateVelocityFromWep:self.holder.position toFinger:endPoint];
        thrownShape->SetLinearVelocity(b2Vec2(vel.x, vel.y));
        
        
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
    if (dist > MAXTHROWNSPEED)dist= MAXTHROWNSPEED;
    dist                    = dist / 64;
    float angle             = atan2f(startPoint.y-endPoint.y, startPoint.x - endPoint.x);
    self.wepAngle           = angle;
    float vx                = cosf(angle)*dist;
    float vy                = sinf(angle)*dist;
    vel                     = CGPointMake(vx, vy);
    
    //KUNAIS R FASTER
    return ccpMult(vel, 4.);
}

@end
