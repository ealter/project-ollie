//
//  VortexPill.h
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWThrownWeapon.h"

#define VPILL_WIDTH (30./PTM_RATIO)
#define VPILL_HEIGHT (30./PTM_RATIO)
#define VPILL_IMAGE_1 @"vpill_1.png"
#define VPILL_IMAGE_2 @"vpill_2.png"
#define VPILL_IMAGE_3 @"vpill_3.png"
#define VPILL_IMAGE_4 @"vpill_4.png"

@interface VortexPill : GWThrownWeapon {
    float spin;
}

//Extra sprites for effect
@property (strong, nonatomic) CCSprite *pill1;
@property (strong, nonatomic) CCSprite *pill2;
@property (strong, nonatomic) CCSprite *pill3;


-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
