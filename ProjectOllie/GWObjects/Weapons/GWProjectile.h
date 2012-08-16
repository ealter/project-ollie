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
    b2World* _world;    //Box2D world
    float destroyTimer; //Timer that keeps bullets from living forever
}

//Gameworld, which all things are added to
@property (strong, nonatomic) ActionLayer *gameWorld;

//BOOL used by contact listener
@property (assign, nonatomic) BOOL bulletCollided;

//Emitter used for effects
@property (strong, nonatomic) CCParticleSystem *emitter;

//Timer for thrown weapons, can also be used for bullets
@property (assign, nonatomic) float fuseTimer;


//Big init to make the bullet, called by sub bullets
-(id)initWithBulletSize:(CGSize)size imageName:(NSString *)imageName startPosition:(CGPoint)pos b2World:(b2World *)world b2Bullet:(BOOL) isBullet gameWorld:(ActionLayer *) gWorld;

//method to remove bullet from the b2world and from the game
-(void)destroyBullet;

//Method that applies a force to b2bodies in a certain radius
-(void)applyb2ForceInRadius:(float) maxDistance withStrength:(float)str isOutwards:(BOOL)outwards;

//Method called by the contact listener
-(void)bulletContact;


@end
