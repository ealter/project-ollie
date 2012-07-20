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

@interface GWThrownWeapon()
{
    NSString *_imageName;
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
        _world = world;
        
        
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

@end
