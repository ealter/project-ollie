
//
//  GWUILayer.h
//  ProjectOllie
//
//  Created by Lion User on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWWeaponTable.h"

@class GWCharacterAvatar;
@class CCParticleSystem;

@interface GWUILayer : CCLayer <SWTableViewDataSource, SWTableViewDelegate> {
    NSUInteger numCells;
    int wepIterator;
}

@property (strong, nonatomic) GWWeaponTable* weaponTable;

@property (strong, nonatomic) GWCharacterAvatar* activeCharacter; // Character currently selected

@property (strong, nonatomic) CCParticleSystem* emitter; //Particle emitter

-(void)buildWeaponTableFrom:(GWCharacterAvatar *)character;   // BUIld a weapon table from a character

@end
