//
//  Bazooka.h
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWGunWeapon.h"

#define BAZOOKA_WIDTH (100./PTM_RATIO)
#define BAZOOKA_HEIGHT (90./PTM_RATIO)
#define BAZOOKA_IMAGE @"bazooka.png"
#define BAZOOKA_B_WIDTH 10.
#define BAZOOKA_B_HEIGHT 6.
#define BAZOOKA_B_IMAGE @"bullet.png"

class b2World;
@class ActionLayer;

@interface Bazooka : GWGunWeapon 

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
