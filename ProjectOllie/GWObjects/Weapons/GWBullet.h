//
//  GWBullet.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "GWPhysicsSprite.h"

class b2World;

@interface GWBullet : GWPhysicsSprite {
    b2World* _world;
}

-(id)initWithBulletSize:(CGSize)size imageName:(NSString *)imageName startPosition:(CGPoint)pos b2World:(b2World *)world b2Bullet:(BOOL) isBullet;

-(void)destroyBullet;

@end