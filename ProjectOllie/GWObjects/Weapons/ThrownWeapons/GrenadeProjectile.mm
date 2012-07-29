//
//  Grenade_Projectile.m
//  ProjectOllie
//
//  Created by Lion User on 7/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GrenadeProjectile.h"
#import "Box2D.h"
#import "Grenade.h"
#import "GameConstants.h"


@implementation GrenadeProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world
{
    if (self = [super initWithBulletSize:CGSizeMake(GRENADE_WIDTH*PTM_RATIO, GRENADE_HEIGHT*PTM_RATIO) imageName:GRENADE_IMAGE startPosition:pos b2World:world b2Bullet:YES]) {
        
        
    }
    
    return self;
}


-(void)destroyBullet
{
    
    
    [super destroyBullet];
}

@end
