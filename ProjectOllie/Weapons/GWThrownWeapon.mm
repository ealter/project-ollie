//
//  GWThrownWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWThrownWeapon.h"

@interface GWThrownWeapon()

//Box2D body for the projectile
@property (assign, nonatomic) b2Body *box2DBody;

@end

@implementation GWThrownWeapon
@synthesize box2DBody       = _box2DBody;

@end
