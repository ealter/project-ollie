//
//  GWGunWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWGunWeapon.h"

@interface GWGunWeapon ()
//Bullet Child
@property (strong, nonatomic) GWBullet *bullets;

//Method for firing the weapon
-(void)fireWeapon:(CGPoint) target;

@end

@implementation GWGunWeapon
@synthesize bullets         = _bullets;

-(void)fireWeapon:(CGPoint)target
{
    _bullets = [[GWBullet alloc]init];
}

@end
