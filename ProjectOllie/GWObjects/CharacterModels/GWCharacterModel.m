//
//  GWCharacterModel.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/6/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "GWCharacterModel.h"

//Serialization constants
static const NSString *kSelectedWeaponTypeKey = @"Current weapon";
static const NSString *kPositionKey           = @"Position";

static NSDictionary *CGPointToDictionary(CGPoint p) {
    NSNumber *x = [NSNumber numberWithFloat:p.x];
    NSNumber *y = [NSNumber numberWithFloat:p.y];
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:x,y, nil] forKeys:[NSArray arrayWithObjects:@"x",@"y", nil]];
}

static CGPoint dictionaryToCGPoint(NSDictionary *dict) {
    float x = [(NSNumber *)[dict objectForKey:@"x"] floatValue];
    float y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
    return CGPointMake(x, y);
}

@implementation GWCharacterModel
@synthesize position = _position;
@synthesize selectedWeapon = _selectedWeapon;

- (id)initWithJsonData:(id)jsonData
{
    if(self = [self init]) {
        if(![jsonData isKindOfClass:[NSDictionary class]]) {
            DebugLog(@"I received data that should have been a dictionary, but was not");
            return nil;
        }
        _position = dictionaryToCGPoint([jsonData objectForKey:kPositionKey]);
        _selectedWeapon = [(NSDecimalNumber *)[jsonData objectForKey:kSelectedWeaponTypeKey] intValue];
    }
    return self;
}

- (id)serializeToJsonData
{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
    [data setObject:[NSNumber numberWithInt:self.selectedWeapon] forKey:kSelectedWeaponTypeKey];
    [data setObject:CGPointToDictionary(self.position) forKey:kPositionKey];
    return data;
}

+ (NSString *)imageNameForWeaponType:(weaponType)weaponType
{
    return nil;
}

+ (NSArray *)weaponTypes
{
    return nil;
}

- (NSArray *)availableWeapons
{
    return availableWeapons_;
}

@end
