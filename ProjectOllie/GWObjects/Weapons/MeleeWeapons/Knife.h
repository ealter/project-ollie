//
//  Knife.h
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWMeleeWeapon.h"

#define KNIFE_WIDTH (11./PTM_RATIO)
#define KNIFE_HEIGHT (30./PTM_RATIO)
#define KNIFE_IMAGE @"knife.png"

@interface Knife : GWMeleeWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
