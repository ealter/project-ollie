//
//  GWParallaxNode.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/21/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#import "GWParallaxNode.h"


@implementation GWParallaxNode

-(id)init{
    if((self = [super init]))
    {
        CCDirector *director = [CCDirector sharedDirector];
        [[director touchDispatcher] addStandardDelegate:self priority:0];
    }
    return self;
}

@end
