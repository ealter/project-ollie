//
//  GWGunWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWWeapon.h"

class b2World;

@interface GWGunWeapon : GWWeapon {
    b2World *_world;
}

-(id)initGunWithImage: (NSString *)imageName andPosition:(CGPoint) pos andSize:(CGSize) size bulletSize:(CGSize) bSize bulletSpeed:(float)bSpeed bulletImage:(NSString *)bImage box2DWorld: (b2World *)world;

@end
