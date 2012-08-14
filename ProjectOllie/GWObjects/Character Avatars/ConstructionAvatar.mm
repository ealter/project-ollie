//
//  ConstructionAvatar.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 8/8/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "ConstructionAvatar.h"
#import "ConstructionModel.h"

@interface ConstructionAvatar()
{
    ConstructionModel* _model;
}


@end

@implementation ConstructionAvatar

-(id)initWithModel:(GWCharacterModel *)model box2DWorld:(b2World *)world{
    
    if((self = [super initWithIdentifier:@"construction" spriteIndices:nil box2DWorld:world]))
    {
                    
    }
    return self;
}

-(id)initWithSpriteIndices:(NSArray*)indices box2DWorld:(b2World*)world
{
    if((self = [super initWithIdentifier:@"construction" spriteIndices:indices box2DWorld:world]))
    {
                    
    }
    return self;
}

-(GWCharacterModel*)model{

    return (GWCharacterModel*)_model;
}

@end
