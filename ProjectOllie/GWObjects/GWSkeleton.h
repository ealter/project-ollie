//
//  GWSkeleton.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/10/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#include <string>

class Skeleton;
struct Bone;
class b2World;


/********
 * TODO *
 ********
 - Add boolean ragdoll mode
 - Add sensor body that interacts with physics. The body is tied to this during animation
 - When the body is in ragdoll mode, the sensor becomes inactive and is tied to the body
 */
@interface GWSkeleton : CCNode {
    Skeleton* _skeleton;
    NSString* skeletonName;
}

/* Initializes skeleton with given file name. Path not necessary */
-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World*)world;
-(Bone*)getBoneByName:(NSString*)bName;
-(Skeleton*)getSkeleton;
-(void)update:(float)dt;
-(void)runAnimation:(NSString*)animationName;
-(void)applyLinearImpulse:(CGPoint)impulse;
-(void)loadAnimations:(NSArray*) animationNames;

@end
