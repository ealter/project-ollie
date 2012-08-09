//
//  ConstructionAvatar.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 8/8/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "ConstructionAvatar.h"


@implementation ConstructionAvatar

-(id)initWithSpriteIndices:(NSArray*)indices box2DWorld:(b2World*)world
{
    if((self = [super initWithIdentifier:@"construction" spriteIndices:indices box2DWorld:world]))
        {
                    
        }
    return self;
}

@end
