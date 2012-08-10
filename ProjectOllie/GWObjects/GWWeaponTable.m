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


+(id)viewWithDataSource:(id<SWTableViewDataSource>)dataSource size:(CGSize)size{
    
    GWWeaponTable* tv  = [self viewWithDataSource:dataSource size:size container:nil];
    /* init values */
    tv.clipsToBounds = NO;
    [tv scheduleUpdate];
    return tv;
    
}

-(void)update:(ccTime) dt
{
    for (SWTableViewCell* cell in self->cellsUsed_) {
        
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return NO;

}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];    
}

@end
