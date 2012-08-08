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
    NSMutableArray *availableWeapons_; //Subclasses should initialize this
}

@property (nonatomic) weaponType selectedWeapon;
@property (nonatomic) CGPoint position; //in meters

//jsonData is nsdecimalnumbers, nsnumbers, nsdictionaries, and nsarrays
- (id)initWithJsonData:(NSDictionary *)jsonData;
- (NSDictionary *)serializeToJsonData;

- (NSArray *)availableWeapons; //The weapons that have been unlocked

//Subclasses should override these methods:
+ (NSString *)imageNameForWeaponType:(weaponType)weaponType; //TODO: Maybe return a weapon class?
+ (NSArray *)weaponTypes; //All weapons available to this character class

@end
