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
static const NSString *kBodyIndexesKey        = @"Body types";

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
@synthesize selectedWeapon = _selectedWeapon;

- (id)init {
    if(self = [super init]) {
        bodyTypesIndexes_ = [NSMutableArray array];
    }
    return self;
}

- (id)initWithJsonData:(NSDictionary *)jsonData
{
    if(self = [self init]) {
        if(![jsonData isKindOfClass:[NSDictionary class]]) {
            DebugLog(@"I received data that should have been a dictionary, but was not");
            return nil;
        }
        _selectedWeapon = [(NSDecimalNumber *)[jsonData objectForKey:kSelectedWeaponTypeKey] intValue];
        bodyTypesIndexes_ = [jsonData objectForKey:kBodyIndexesKey];
    }
    return self;
}

- (NSDictionary *)serializeToJsonData
{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
    [data setObject:[NSNumber numberWithInt:self.selectedWeapon] forKey:kSelectedWeaponTypeKey];
    [data setObject:bodyTypesIndexes_ forKey:kBodyIndexesKey];
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

- (NSMutableArray *)availableWeapons
{
    return availableWeapons_;
}

- (void)setBodyType:(int)bodyType atIndex:(int)index
{
    if(index < 0) {
        @throw NSRangeException;
    }
    for(int i=bodyTypesIndexes_.count; i<=index; i++) {
        [bodyTypesIndexes_ addObject:[NSNumber numberWithInt:kUnusedBone]];
    }
    [bodyTypesIndexes_ replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:bodyType]];
}

- (int)bodyTypeAtIndex:(int)index
{
    return [(NSNumber *)[bodyTypesIndexes_ objectAtIndex:index] intValue];
}

- (int)numBodyParts
{
    return bodyTypesIndexes_.count;
}

@end
