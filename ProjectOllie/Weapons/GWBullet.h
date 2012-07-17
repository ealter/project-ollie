//
//  GWBullet.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "PhysicsSprite.h"

class b2World;

@interface GWBullet : CCNode {
    b2World* _world;
}

//Projectile Speed
@property (assign, nonatomic) float bulletSpeed;

//Bullet Size
@property (assign, nonatomic) CGSize bulletSize;

//Bullet Sprite
@property (strong, nonatomic) PhysicsSprite *bulletSprite;


-(id)initWithBulletSize:(CGSize)size image:(NSString *)imageName startPosition:(CGPoint)pos target:(CGPoint)target b2World:(b2World *)world bulletSpeed:(float)speed;

@end
