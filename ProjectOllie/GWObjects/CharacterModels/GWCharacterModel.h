//
//  GWCharacterModel.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/6/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//
//  This is an abstract class.
//

#import <Foundation/Foundation.h>

typedef int weaponType; //Subclasses should probably use some kind of enum for this

@interface GWCharacterModel : NSObject {
    NSMutableArray *availableWeapons_; //TODO: should this be an NSArray?
}

@property (nonatomic) weaponType selectedWeapon;
@property (nonatomic) CGPoint position; //in meters

- (NSArray *)availableWeapons; //The weapons that have been unlocked

//Subclasses should override these methods:
+ (NSString *)imageNameForWeaponType:(weaponType)weaponType;
+ (NSArray *)weaponTypes; //All weapons available to this character class

@end
