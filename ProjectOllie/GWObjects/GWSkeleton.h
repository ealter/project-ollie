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
 - MAKE INTERACTOR OBJECT WITH CIRCLE AND SQUARE
 */

/******************************
 ****** Interactor class ******
 ******************************/

class b2ContactEdge;
class b2Body;

typedef enum InteractorState{
    kInteractorStateActive = 0,
    kInteractorStateInactive,
    kInteractorStateRagdoll
} InteractorState;

@interface Interactor : NSObject{
    
}

@property (assign, nonatomic)   InteractorState state;
@property (readonly, nonatomic) b2Body* interactingBody;

-(id)initAsBoxAt:(CGPoint)location inWorld:(b2World*)world;
-(id)initAsCircleAt:(CGPoint)location inWorld:(b2World*)world;
-(CGPoint)getLinearVelocity;
-(void)setLinearVelocity:(CGPoint)lv;
-(float)getAngularVelocity;
-(void)setAngularVelocity:(float)av;
-(CGPoint)getPosition;
-(void)setPosition:(CGPoint)position;
-(CGPoint)getAbsolutePosition;
-(void)applyLinearImpulse:(CGPoint)impulse;
-(void)setPositionInSkeleton:(Skeleton*)_skeleton;
-(void)update;
-(float)getRadius;
-(float)calculateNormalAngle;
-(b2Body*)getBox;
-(b2Body*)getWheel;

@end

@interface GWSkeleton : CCNode {
    Skeleton* _skeleton;
    NSString* skeletonName;
}

@property (assign, nonatomic) bool animating;
@property (strong, nonatomic) Interactor* interactor;

/* Initializes skeleton with given file name. Path not necessary */
-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World*)world;

/* Gets a given bone by NSString representation of its name */
-(Bone*)getBoneByName:(NSString*)bName;

/* Updates the GWSkeleton */
-(void)update:(float)dt;

/* Puts the animation into the skeleton's animation queue */
-(void)runAnimation:(NSString*)animationName flipped:(bool)flipped;

/* Applies a linear impulse to the skeleton's interactor */
-(void)applyLinearImpulse:(CGPoint)impulse;

/* Loads an animation into the animation dictionary */
-(void)loadAnimations:(NSArray*) animationNames;

/* Clears the animation queue of the skeleton */
-(void)clearAnimation;

/* Calculate's angle for skeleton based on interactor's normal to ground body. Returns whether or not there is one*/
-(bool)calculateNormalAngle;

/* Sets the interactor velocity */
-(void)setVelocity:(CGPoint)vel;

/* Gets the interactor velocity */
-(CGPoint)getVelocity;

/* Sets the interactor's position to the lowest point of a ragdoll */
-(void)setInteractorPositionInRagdoll;

/* Puts the animation into the skeleton's animation queue */
-(void)runAnimation:(NSString*)animationName WithTweenTime:(float)duration flipped:(bool)flipped;

/* Sets the skeleton's position relative to interactor's */
-(void)tieSkeletonToInteractor;

/* Sets the skeleton to active or inactive */
-(void)setActive:(bool)active;

/* Tells the skeleton which character owns it */
-(void)setOwner:(id)owner;

-(bool)resting;


@end
