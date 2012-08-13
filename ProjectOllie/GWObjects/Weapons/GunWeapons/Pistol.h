//
//  Pistol.h
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWGunWeapon.h"

#define PISTOL_WIDTH (25./PTM_RATIO)
#define PISTOL_HEIGHT (16./PTM_RATIO)
#define PISTOL_IMAGE @"pistol.png"
#define PISTOL_B_WIDTH 10.
#define PISTOL_B_HEIGHT 6.
#define PISTOL_B_IMAGE @"bullet.png"

@interface Pistol : GWGunWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;


@end
