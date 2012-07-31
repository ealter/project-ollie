//
//  GWCharacter.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/23/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

class b2World;
@class GWSkeleton;

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

@interface GWCharacter : CCNode {
    
}
-(id)initWithIdentifier:(NSString*)type spriteIndices:(NSArray*)indices box2DWorld:(b2World*)world;
-(void)update:(float)dt;
-(void)walkLeft;
-(void)walkRight;
-(void)stopWalking;

//Properties endemic to character
@property (strong, nonatomic) GWSkeleton* skeleton;

/* The current state of the GWCharacter */
@property (assign, nonatomic) characterState state;

@end
