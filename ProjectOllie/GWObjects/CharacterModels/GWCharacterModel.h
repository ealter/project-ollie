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

enum {
    kUnusedBone = -1
};

@interface GWCharacterModel : NSObject {
    NSMutableArray *availableWeapons_; //Subclasses should initialize this
    NSMutableArray *bodyTypesIndexes_;
}

@property (nonatomic) weaponType selectedWeapon;

//jsonData is nsdecimalnumbers, nsnumbers, nsdictionaries, and nsarrays
- (id)initWithJsonData:(NSDictionary *)jsonData;
- (NSDictionary *)serializeToJsonData;

- (NSMutableArray *)availableWeapons; //The weapons that have been unlocked

//Accessor methods for bodyTypesIndexes_. I use this wrapper so that we can set a value at any index (even if the array isn't big enough yet)
- (void)setBodyType:(int)bodyType atIndex:(int)index;
- (int)bodyTypeAtIndex:(int)index;
- (int)numBodyParts;

//Subclasses should override these methods:
+ (NSString *)imageNameForWeaponType:(weaponType)weaponType; //TODO: Maybe return a weapon class?
+ (NSArray *)weaponTypes; //All weapons available to this character class

@end
