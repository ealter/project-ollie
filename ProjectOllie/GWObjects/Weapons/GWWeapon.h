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
#import "GWCharacterAvatar.h"

typedef enum wepType {
    kType2HGun = 0, // 2 Handed Gun
    kType1HGun,     // 1 Handed Gun
    kTypeThrown,    // Thrown Weapon
    kType2HMelee,   // 2 Handed Melee
    kType1HMelee    // 1 Handed Melee
} wepType;

@interface GWWeapon : CCSprite

//Weapon damage
@property (assign, nonatomic) float damage;

//Ammo/Uses for the weapon
@property (assign, nonatomic) int ammo;

//Gun's owner/user
@property (strong, nonatomic) GWCharacterAvatar *holder;

//Gun's image
@property (assign, nonatomic) NSString* weaponImage;

//Gun's title
@property (assign, nonatomic) NSString* title;

//Gun's description
@property (assign, nonatomic) NSString* description;

//Gun's type
@property (assign, nonatomic) wepType type;

//weapon availability
@property (assign, nonatomic, getter = isUnlocked) BOOL unlocked;

//onscreen representation
@property (strong, nonatomic) CCSprite *weaponSprite;

@property (assign, nonatomic) float wepAngle;

@property (strong, nonatomic) ActionLayer *gameWorld;

//Empty method for firing weapon, should be overwritten
-(void)fireWeapon:(CGPoint) target;

//Empty method for filling title and description of weapon, should be overwritten
-(void)fillDescription;

//Empty method for throwing weapon, should be overwritten
-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint;

@end
