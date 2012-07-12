//
//  GWSkeleton.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/10/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#include "Skeleton.h"

@interface GWSkeleton : CCNode {
    Skeleton* _skeleton;
}
-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World*)world;
-(Bone*)getBoneByName:(NSString*)bName;
-(Skeleton*)getSkeleton;
-(void)update:(float)dt;


@end
