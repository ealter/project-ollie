//
//  GWWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWWeapon.h"

@implementation GWWeapon
@synthesize damage          = _damage;
@synthesize ammo            = _ammo;
@synthesize unlocked        = _unlocked;
@synthesize weaponSprite    = _weaponSprite;
@synthesize gameWorld       = _gameWorld;
@synthesize wepAngle        = _wepAngle;
@synthesize holder          = _holder;
@synthesize weaponImage     = _weaponImage;
@synthesize title           = _title;
@synthesize description     = _description;

-(void)fireWeapon:(CGPoint)target
{
    
}

-(void)fillDescription
{
    self.title          = @"";
    self.description    = @"";
}

-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    
}


@end
