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
    }
    
    return self;
}

-(void)draw{
    CCLOG(@"Drawing at: (%f,%f)",self.position.x,self.position.y);
    [super draw];
}

-(void)update:(ccTime) dt
{
    
}


@end
