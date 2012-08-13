//
//  GWGunWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWWeapon.h"
#import "GWGestures.h"

class b2World;
@class HMVectorNode;

#define MAXSPEED 10. //Maximum speed of the weapon's projectile

@interface GWGunWeapon : GWWeapon<GestureChild> {
    b2World         *_world;   //Box2D world
    HMVectorNode    *drawNode; //Draws trajectory to screen
    CGPoint         shootPoint;//Used to track where the rotation was last set to
    
}

//These variables should be redefined within each type of weapon
@property (assign, nonatomic) CGSize    bulletSize;
@property (strong, nonatomic) NSString  *bulletImage;

//Speed of the bullet
@property (assign, nonatomic) float     bulletSpeed;

//Images for the overlay and the gun
@property (strong, nonatomic) CCSprite  *aimOverlay;
@property (strong, nonatomic) CCSprite  *gunImage;

//Huge init, called by weapons
-(id)initWithImage:(NSString *)imageName position:(CGPoint) pos size:(CGSize)size ammo:(float) ammo bulletSize:(CGSize)bulletSize bulletSpeed:(float)bulletSpeed bulletImage:(NSString *)bulletImage box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

//Calculates the angle of the gun and the speed of the bullets
-(CGPoint)calculateGunVelocityFromStart:(CGPoint) startPoint toAimPoint:(CGPoint) aimPoint;

//Uses the HMKVectorNode to draw a trajectory on the screen
-(void)simulateTrajectoryWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint;

@end
