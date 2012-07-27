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

typedef enum characterState {
    kStateIdle = 0,   // when just standing around
    kStateWalking,    // when walking (in whatever direction)
    kStateRagdoll,    // when in Ragdoll mode
    kStateArming,     // when using a weapon
    kStateManeuvering // ???
} characterState;

typedef enum Orientation {
    kOrientationLeft = 0,
    kOrientationRight
}Orientation;

@interface GWCharacter : CCNode {
    
}
-(id)initWithIdentifier:(NSString*)type spriteIndices:(NSArray*)indices box2DWorld:(b2World*)world;
-(void)update:(float)dt;
-(void)walkLeft;
-(void)walkRight;
-(void)stopWalking;

//Properties endemic to character

@end
