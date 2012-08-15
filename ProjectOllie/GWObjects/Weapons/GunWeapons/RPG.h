//
//  RPG.h
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWGunWeapon.h"

#define RPG_WIDTH (70./PTM_RATIO)
#define RPG_HEIGHT (30./PTM_RATIO)
#define RPG_IMAGE @"rocket_launcher.png"
#define RPG_B_WIDTH 10.
#define RPG_B_HEIGHT 10.
#define RPG_B_IMAGE @"rocket.png"

@interface RPG : GWGunWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;


@end
