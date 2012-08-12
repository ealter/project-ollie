//
//  GWProjectile.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWPhysicsSprite.h"
#import "ActionLayer.h"

class b2World;
@class CCParticleSystem;

@interface GWProjectile : GWPhysicsSprite {
    b2World* _world;
    float destroyTimer;
}

@property (strong, nonatomic) ActionLayer *gameWorld;
@property (assign, nonatomic) BOOL bulletCollided;
@property (strong, nonatomic) CCParticleSystem *emitter;
@property (assign, nonatomic) float fuseTimer;

-(id)initWithBulletSize:(CGSize)size imageName:(NSString *)imageName startPosition:(CGPoint)pos b2World:(b2World *)world b2Bullet:(BOOL) isBullet gameWorld:(ActionLayer *) gWorld;

-(void)destroyBullet;

-(void)applyb2ForceInRadius:(float) maxDistance withStrength:(float)str isOutwards:(BOOL)outwards;

-(void)bulletContact;


@end
