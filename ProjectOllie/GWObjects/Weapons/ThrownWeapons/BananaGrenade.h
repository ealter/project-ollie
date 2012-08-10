//
//  BananaGrenade.h
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWThrownWeapon.h"

#define CLUSTER_WIDTH (30./PTM_RATIO)
#define CLUSTER_HEIGHT (30./PTM_RATIO)
#define CLUSTER_IMAGE @"banana_grenade.png"
#define SINGLE_WIDTH (30./PTM_RATIO)
#define SINGLE_HEIGHT (30./PTM_RATIO)
#define SINGLE_IMAGE @"banana.png"


@interface BananaGrenade : GWThrownWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
