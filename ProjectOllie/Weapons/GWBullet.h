//
//  GWBullet.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "PhysicsSprite.h"


@interface GWBullet : CCNode {
    b2World* _world;
}

//Projectile Speed
@property (assign, nonatomic) float bulletSpeed;

//Bullet Size
@property (assign, nonatomic) CGSize bulletSize;

//Bullet Sprite
@property (strong, nonatomic) PhysicsSprite *bulletSprite;


-(id)initWithBulletSize:(CGSize) size andImage:(NSString *)imageName andStartPosition:(CGPoint) pos andTarget:(CGPoint) target b2World: (b2World *)world bulletSpeed:(float) speed;
@end
