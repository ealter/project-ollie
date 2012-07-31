//
//  GWProjectile.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "GWPhysicsSprite.h"
#import "ActionLayer.h"


class b2World;

@interface GWProjectile : GWPhysicsSprite {
    b2World* _world;
}

@property (strong, nonatomic) ActionLayer *gameWorld;

-(id)initWithBulletSize:(CGSize)size imageName:(NSString *)imageName startPosition:(CGPoint)pos b2World:(b2World *)world b2Bullet:(BOOL) isBullet gameWorld:(ActionLayer *) gWorld;

-(void)destroyBullet;

-(void)applyb2ForceInRadius:(float) maxDistance withStrength:(float)str isOutwards:(BOOL)outwards;

@end
