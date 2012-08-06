//
//  Shotgun.h
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWGunWeapon.h"
#include "GameConstants.h"

#define SHOTGUN_WIDTH 100./PTM_RATIO
#define SHOTGUN_HEIGHT 90./PTM_RATIO
#define SHOTGUN_IMAGE @"shotgun.png"
#define SHOTGUN_B_WIDTH 5.
#define SHOTGUN_B_HEIGHT 5.
#define SHOTGUN_B_IMAGE @"pellet.png"
#define SHOTGUN_B_LIFE 2.
#define NUM_PELLETS 6

@interface Shotgun : GWGunWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
