//
//  GWWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ActionLayer.h"
#import "GWCharacter.h"

@interface GWWeapon : CCSprite

//Weapon damage
@property (assign, nonatomic) float damage;

//Ammo/Uses for the weapon
@property (assign, nonatomic) float ammo;

//Gun's owner/user
@property (strong, nonatomic) GWCharacter *holder;

//weapon availability
@property (assign, nonatomic, getter = isUnlocked) BOOL unlocked;

//onscreen representation
@property (strong, nonatomic) CCSprite *weaponSprite;

@property (assign, nonatomic) float wepAngle;

@property (strong, nonatomic) ActionLayer *gameWorld;

//Empty method for firing weapon, should be overwritten
-(void)fireWeapon:(CGPoint) target;

//Empty method for throwing weapon, should be overwritten
-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint;

@end
