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

/* Gets a given bone by NSString representation of its name */
-(Bone*)getBoneByName:(NSString*)bName;

/* Updates the GWSkeleton */
-(void)update:(float)dt;

/* Puts the animation into the skeleton's animation queue */
-(void)runAnimation:(NSString*)animationName;

/* Applies a linear impulse to the skeleton's interactor */
-(void)applyLinearImpulse:(CGPoint)impulse;

/* Loads an animation into the animation dictionary */
-(void)loadAnimations:(NSArray*) animationNames;

/* Clears the animation queue of the skeleton */
-(void)clearAnimation;

@end
