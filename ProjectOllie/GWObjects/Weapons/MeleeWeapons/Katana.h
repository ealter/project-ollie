//
//  Katana.h
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWMeleeWeapon.h"

#define KATANA_WIDTH (11./PTM_RATIO)
#define KATANA_HEIGHT (60./PTM_RATIO)
#define KATANA_IMAGE @"katana.png"

@interface Katana : GWMeleeWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
