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

typedef enum characterStates {
    kStateIdle = 0,
    kStateWalking,
    kStateRagdoll
} characterStates;

@interface GWCharacter : CCNode {
    
}
-(id)initWithIdentifier:(NSString*)type spriteIndices:(NSArray*)indices box2DWorld:(b2World*)world;

//Properties endemic to character

@end
