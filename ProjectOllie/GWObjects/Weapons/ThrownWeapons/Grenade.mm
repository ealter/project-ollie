//
//  Grenade.m
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "Grenade.h"
#import "GameConstants.h"
#import "GrenadeProjectile.h"

@implementation Grenade

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:GRENADE_IMAGE position:pos size:CGSizeMake(GRENADE_WIDTH, GRENADE_HEIGHT) ammo:ammo box2DWorld:world fuseTime:4 gameWorld:gWorld]) {
        
    }
    
    return self;
}


-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    if (self.ammo >0) {
        //Make a bullet which acts as the thrown item
        thrown              = [[GrenadeProjectile alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
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


@end
