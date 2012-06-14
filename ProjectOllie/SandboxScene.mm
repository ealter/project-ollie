//
//  SandboxScene.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SandboxScene.h"
#import "ActionLayer.h"

@implementation SandboxScene

@synthesize actionLayer = _actionLayer;

-(id) init
{
    if (self = [super init]) {
        // 'layer' is an autorelease object.
        self.actionLayer = [ActionLayer node];
        
        // add layer as a child to scene
        [self addChild: self.actionLayer];
        
        /*
        Background *blayer = [Background node];
        [blayer initwithSpeed:3 andImage:@"background.jpg"];
        [self addChild:blayer];
        [self reorderChild:blayer z:-100];*/
    }
    return self;
}

@end
