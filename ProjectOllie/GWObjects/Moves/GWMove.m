//
//  GWMove.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/23/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "GWMove.h"
#import "NSString+SBJSON.h"

@implementation GWMove

- (id)init
{
    if(self = [super init]) {
        moves_ = [NSMutableArray array];
    }
    return self;
}
- (void)deserialize:(NSString *)data
{
    
}

- (NSString *)serialize
{
    return nil;
}

- (void)startMove
{
    [self scheduleUpdate];
}

- (void)stopMove
{
    [self unscheduleUpdate];
}

- (void)update:(ccTime)dt
{
    
}

@end
