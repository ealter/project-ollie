//
//  GaussRifle.h
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWGunWeapon.h"

#define GAUSS_WIDTH (60./PTM_RATIO)
#define GAUSS_HEIGHT (20./PTM_RATIO)
#define GAUSS_IMAGE @"gauss_rifle.png"
#define GAUSS_B_WIDTH 10.
#define GAUSS_B_HEIGHT 6.
#define GAUSS_B_IMAGE @"bullet.png"

@interface GaussRifle : GWGunWeapon

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
