//
//  GWMoveEvent.m
//  ProjectOllie
//
//  Created by Eliot Alter on 7/23/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "GWMoveFrame.h"

@implementation GWMoveFrame
@synthesize time = _time;

- (id)init
{
    return [self initWithSerializedData:nil];
}

- (id)initWithSerializedData:(id)data
{
    if(self = [super init]) {
        
    }
    return self;
}

- (id)serializableData
{
    return nil; //TODO
}

@end
