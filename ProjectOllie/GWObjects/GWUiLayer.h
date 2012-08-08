//
//  GWUiLayer.h
//  ProjectOllie
//
//  Created by Lion User on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SWTableView.h"

@class GWCharacter;

@interface GWUiLayer : CCLayer <SWTableViewDataSource, SWTableViewDelegate> {
    NSUInteger numCells;
    int wepIterator;
}

@property (strong, nonatomic) SWTableView* weaponTable;

@property (strong, nonatomic) GWCharacter* activeCharacter; // Character currently selected

@property (strong, nonatomic) CCParticleSystem* emitter; //Particle emitter


-(void)buildWeaponTableFrom:(GWCharacter *)character;   // Build a weapon table from a character


@end
