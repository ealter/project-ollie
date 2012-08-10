//
//  GWWeaponTable.m
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWWeaponTable.h"
#import "MyCell.h"


@implementation GWWeaponTable

-(id)init{
    if (self = [super init]) {
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
    }
    
    return self;
}

-(void)update:(ccTime) dt
{
    for (SWTableViewCell* cell in self->cellsUsed_) {
        
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    DebugLog(@"GALKDFJ");
    return YES;
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];    
}

@end
