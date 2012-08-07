//
//  GWCharacterModel.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/6/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "GWCharacterModel.h"

@implementation GWCharacterModel
@synthesize position = _position;
@synthesize selectedWeapon = _selectedWeapon;

+ (NSString *)imageNameForWeaponType:(weaponType)weaponType
{
    return nil;
}

+ (NSArray *)weaponTypes
{
    return nil;
}

- (NSArray *)availableWeapons
{
    return availableWeapons_;
}

@end
