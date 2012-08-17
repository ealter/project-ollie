//
//  Kunai.h
//  ProjectOllie
//
//  Created by Lion User on 8/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWThrownWeapon.h"

#define KUNAI_WIDTH (25./PTM_RATIO)
#define KUNAI_HEIGHT (5./PTM_RATIO)
#define KUNAI_IMAGE @"kunai.png"

@interface Kunai : GWThrownWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
