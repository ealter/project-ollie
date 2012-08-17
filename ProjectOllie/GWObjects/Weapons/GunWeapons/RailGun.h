//
//  RailGun.h
//  ProjectOllie
//
//  Created by Lion User on 8/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWGunWeapon.h"

#define RAIL_WIDTH (50./PTM_RATIO)
#define RAIL_HEIGHT (20./PTM_RATIO)
#define RAIL_IMAGE @"railgun.png"
#define RAIL_B_WIDTH 10.
#define RAIL_B_HEIGHT 6.
#define RAIL_B_IMAGE @"bullet.png"

@interface RailGun : GWGunWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
