//
//  Grenade.h
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWThrownWeapon.h"

#define GRENADE_WIDTH 0.1
#define GRENADE_HEIGHT 0.1
#define GRENADE_IMAGE @"Icon-Small.png"


@interface Grenade : GWThrownWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
