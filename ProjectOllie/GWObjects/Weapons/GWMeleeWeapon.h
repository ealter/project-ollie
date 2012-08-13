//
//  GWMeleeWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWWeapon.h"

@interface GWMeleeWeapon : GWWeapon {
    b2World *_world;        //Box2Dworld

}

@end
