//
//  GWSkeleton.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/10/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"

class Skeleton;
struct Bone;
class b2World;

@interface GWSkeleton : CCNode {
    Skeleton* _skeleton;
}
-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World*)world;
-(Bone*)getBoneByName:(NSString*)bName;
-(Skeleton*)getSkeleton;
-(void)update:(float)dt;
-(void)loadAnimation:(string)animationName;

@end
