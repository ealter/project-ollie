//
//  GWWeapon.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWWeapon.h"

@interface GWWeapon()

//Weapon damage
@property (assign, nonatomic) float damage;

//Ammo/Uses for the weapon
@property (assign, nonatomic) float ammo;

//Bool for weapon availability
@property (assign, nonatomic) BOOL unlocked;

//CCSprite for onscreen representation
@property (strong, nonatomic) CCSprite *weaponSprite;

@end

@implementation GWWeapon
@synthesize damage          = _damage;
@synthesize ammo            = _ammo;
@synthesize unlocked        = _unlocked;
@synthesize weaponSprite    = _weaponSprite;

@end
