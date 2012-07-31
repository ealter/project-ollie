//
//  GWThrownWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWWeapon.h"
#import "GWPhysicsSprite.h"
#import "Box2D.h"
#import "GWGestures.h"

@interface GWThrownWeapon : GWWeapon <GestureChild>{
    b2World *_world;
}

-(id)initThrownWithImage:(NSString *)imageName position:(CGPoint) pos size:(CGSize)size ammo:(float) ammo box2DWorld: (b2World *)world fuseTime:(float) fuseTime;

-(CGPoint)calculateVelocityFromWep:(CGPoint) startPoint toFinger:(CGPoint) endPoint;

@end