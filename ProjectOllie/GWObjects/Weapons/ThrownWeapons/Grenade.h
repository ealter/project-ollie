//
//  Grenade.h
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWThrownWeapon.h"

#define GRENADE_WIDTH (30./PTM_RATIO)
#define GRENADE_HEIGHT (30./PTM_RATIO)
#define GRENADE_IMAGE @"grenade.png"

@interface Grenade : GWThrownWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
