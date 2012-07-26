//
//  GWMoveEvent.h
//  ProjectOllie
//
//  Created by Eliot Alter on 7/23/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Types of move objects to store:
 *     Collisions
 *     Changing weapon
 *     Keyframe at a constant interval
 */

@interface GWMoveFrame : NSObject

@property (nonatomic) float time; //In seconds relative to the start of the move

- (id)serializableData; //Must be NSNumbers, NSArrays, and/or NSDictionaries
- (id)initWithSerializedData:(id)data; //The data is of the format returned by serializeableData. Data is allowed to be nil

@end
