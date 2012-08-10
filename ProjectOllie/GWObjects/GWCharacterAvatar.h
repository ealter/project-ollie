//
//  GWCharacterAvatar.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/23/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "GWGestures.h"

class b2World;
@class GWSkeleton;
@class GWWeapon;
@class GWUILayer;
@class GWCharacterModel;

typedef enum characterState {
    kStateIdle = 0,   // when just standing around
    kStateWalking,    // when walking (in whatever direction)
    kStateRagdoll,    // when in Ragdoll mode
    kStateArming,     // when using a weapon
    kStateManeuvering // ???
} characterState;

typedef enum Orientation {
    kOrientationRight = 0,
    kOrientationLeft
}Orientation;

@interface GWCharacterAvatar : CCNode <GestureChild>

-(id)initWithIdentifier:(NSString*)type spriteIndices:(NSArray*)indices box2DWorld:(b2World*)world;
-(void)update:(float)dt;

/* Event for walking left */
-(void)walkLeft;

/* Event for walking right */
-(void)walkRight;

/* Event for stopping walking */
-(void)stopWalking;

/* Adds weapons to the weapon pool */
-(void)loadWeapons:(NSArray*)weapons;

//Properties endemic to character

- (GWCharacterModel *)model; //Subclasses MUST override this

/* The weapons available to the character */
@property (strong, nonatomic) NSMutableArray* weapons;

/* The skeleton belonging to the character */
@property (strong, nonatomic) GWSkeleton* skeleton;

/* The current state of the GWCharacterAvatar */
@property (assign, nonatomic) characterState state;

/* The currently active weapon, visible if state == arming */
@property (strong, nonatomic) GWWeapon* selectedWeapon;

/* The UI layer that contains the character*/
@property (strong, nonatomic) GWUILayer* uiLayer;

@end
