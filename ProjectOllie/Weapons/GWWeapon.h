//
//  GWWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GWWeapon : CCSprite

//Weapon damage
@property (assign, nonatomic) float damage;

//Ammo/Uses for the weapon
@property (assign, nonatomic) float ammo;

//weapon availability
@property (assign, nonatomic, getter = isUnlocked) BOOL unlocked;

//onscreen representation
@property (strong, nonatomic) CCSprite *weaponSprite;

//Empty method for firing weapon, should be overwritten
-(void)fireWeapon:(CGPoint) target;

//Empty method for throwing weapon, should be overwritten
-(void)throwWeaponWithAngle:(float) angle withStrength:(float) strength;

@end
