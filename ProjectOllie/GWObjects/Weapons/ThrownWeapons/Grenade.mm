//
//  Grenade.m
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Grenade.h"
#import "GameConstants.h"
#import "GrenadeProjectile.h"

@implementation Grenade

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world
{
    if (self = [super initThrownWithImage:GRENADE_IMAGE position:pos size:CGSizeMake(GRENADE_WIDTH, GRENADE_HEIGHT) ammo:ammo box2DWorld:world fuseTime:4]) {
        
    }
    
    return self;
}


-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    if (self.ammo >0) {
        //Make a bullet which acts as the thrown item
        thrown              = [[GrenadeProjectile alloc] initWithStartPosition:self.position b2World:_world];
        b2Body* thrownShape = thrown.physicsBody;
        [self.parent addChild:thrown];
        
        //Throw the weapon with calculated velocity
        CGPoint vel         = [self calculateVelocityFromWep:startPoint toFinger:endPoint];
        thrownShape->SetLinearVelocity(b2Vec2(vel.x, vel.y));
        self.ammo--;
    }else {
        //no more ammo!
    }
}


@end
