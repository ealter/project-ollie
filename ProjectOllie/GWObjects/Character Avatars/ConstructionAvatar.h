//
//  ConstructionAvatar.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 8/8/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWCharacterAvatar.h"

@interface ConstructionAvatar : GWCharacterAvatar {
    
}

-(id)initWithSpriteIndices:(NSArray*)indices box2DWorld:(b2World*)world;

@end
