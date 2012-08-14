//
//  NailGun.h
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWGunWeapon.h"

#define NAILGUN_WIDTH (40./PTM_RATIO)
#define NAILGUN_HEIGHT (30./PTM_RATIO)
#define NAILGUN_IMAGE @"nail_gun.png"
#define NAILGUN_B_WIDTH 10.
#define NAILGUN_B_HEIGHT 6.
#define NAILGUN_B_IMAGE @"nail.png"

@interface NailGun : GWGunWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
