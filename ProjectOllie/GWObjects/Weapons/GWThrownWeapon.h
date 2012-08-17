//
//  GWThrownWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWWeapon.h"
#import "GWPhysicsSprite.h"
#import "GWGestures.h"
#import "GWProjectile.h"
#import "HMVectorNode.h"

#define MAXTHROWNSPEED 160. //Max speed of the weapon's projectile

class b2World;

@interface GWThrownWeapon : GWWeapon <GestureChild>{
    b2World *_world;        //Box2Dworld
    HMVectorNode *drawNode; //Trajectory is drawn on this
    GWProjectile *thrown;   //Thrown physics sprite subclass
    float fuseTimer;        //Time to explode the thrown item
    float countDown;        //Timer that counts down to explosion
}

//CCSprite used for easy rotation
@property (strong, nonatomic) CCSprite *thrownImage;

//Big init called by inheriting classes
-(id)initWithImage:(NSString *)imageName position:(CGPoint) pos size:(CGSize)size ammo:(float) ammo box2DWorld: (b2World *)world fuseTime:(float) fuseTime gameWorld:(ActionLayer *) gWorld;

//Calculate the thrown object's trajectory and speed, draws trajectory
-(CGPoint)calculateVelocityFromWep:(CGPoint) startPoint toFinger:(CGPoint) endPoint;

//Uses the HMKVectorNode to draw a trajectory on the screen
-(void)simulateTrajectoryWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint;

@end
