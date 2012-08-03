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
#import "Box2D.h"
#import "GWGestures.h"
#import "GWProjectile.h"
#import "HMVectorNode.h"

@interface GWThrownWeapon : GWWeapon <GestureChild>{
    b2World *_world;
    NSString *_imageName;
    HMVectorNode *drawNode;
    GWProjectile *thrown;
    float fuseTimer;
    float countDown;
}

-(id)initWithImage:(NSString *)imageName position:(CGPoint) pos size:(CGSize)size ammo:(float) ammo box2DWorld: (b2World *)world fuseTime:(float) fuseTime gameWorld:(ActionLayer *) gWorld;

-(CGPoint)calculateVelocityFromWep:(CGPoint) startPoint toFinger:(CGPoint) endPoint;

@end
