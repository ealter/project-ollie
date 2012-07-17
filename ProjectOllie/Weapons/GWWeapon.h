//
//  GWWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface GWWeapon : CCNode {
    
}

//Weapon damage
@property (assign, nonatomic) float damage;

//Ammo/Uses for the weapon
@property (assign, nonatomic) float ammo;

//Bool for weapon availability
@property (assign, nonatomic) BOOL unlocked;

//CCSprite for onscreen representation
@property (strong, nonatomic) CCSprite *weaponSprite;

//Empty method for firing weapon, should be overwritten
-(void)fireWeapon:(CGPoint) target;

@end
