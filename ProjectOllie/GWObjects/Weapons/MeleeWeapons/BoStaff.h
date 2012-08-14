//
//  BoStaff.h
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWMeleeWeapon.h"

#define BOSTAFF_WIDTH (11./PTM_RATIO)
#define BOSTAFF_HEIGHT (60./PTM_RATIO)
#define BOSTAFF_IMAGE @"bo_staff.png"

@interface BoStaff : GWMeleeWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
