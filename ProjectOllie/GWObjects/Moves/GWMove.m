//
//  GWMove.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/23/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "GWMove.h"
#import "NSString+SBJSON.h"

@interface GWMove ()

- (void)updateTimerFired:(NSTimer *)timer;

@end

@implementation GWMove
@synthesize moves = _moves;

- (void)deserialize:(NSString *)data
{
    
}

- (NSString *)serialize
{
    return nil;
}

- (void)startMove
{
    if(![updateTimer_ isValid]) {
        updateTimer_ = [NSTimer timerWithTimeInterval:1.0/kGWMovesFPS target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
    }
}

- (void)stopMove
{
    [updateTimer_ invalidate];
}

- (void)updateTimerFired:(NSTimer *)timer
{
    
}

@end
