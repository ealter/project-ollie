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
#import "HMVectorNode.h"

class b2World;

#define MAXSPEED 10. //Maximum speed of the weapon's projectile


@interface GWGunWeapon : GWWeapon<GestureChild> {
    b2World         *_world;
    HMVectorNode    *drawNode;
    CGPoint         shootPoint;//Used to track where the rotation was last set to
    
}
@property (assign, nonatomic) CGSize    bulletSize;
@property (strong, nonatomic) NSString  *bulletImage;
@property (assign, nonatomic) float     bulletSpeed;
@property (strong, nonatomic) CCSprite  *aimOverlay;
@property (strong, nonatomic) CCSprite  *gunImage;

-(id)initWithImage:(NSString *)imageName position:(CGPoint) pos size:(CGSize)size ammo:(float) ammo bulletSize:(CGSize)bulletSize bulletSpeed:(float)bulletSpeed bulletImage:(NSString *)bulletImage box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

-(CGPoint)calculateGunVelocityWithAimPoint:(CGPoint) aimPoint;

-(void)simulateTrajectoryWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint;

@end
