//
//  Grenade_Projectile.h
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWBullet.h"
#import "Box2D.h"


@interface GrenadeProjectile : GWBullet {
    
}

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
