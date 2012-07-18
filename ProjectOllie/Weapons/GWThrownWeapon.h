//
//  GWThrownWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWWeapon.h"
#import "PhysicsSprite.h"
#import "Box2D.h"

@interface GWThrownWeapon : GWWeapon

@property (strong, nonatomic) PhysicsSprite *throwSprite;

-(id)initThrownWithImage:(NSString *)imageName position:(CGPoint) pos size:(CGSize)size box2DWorld: (b2World *)world;

@end
