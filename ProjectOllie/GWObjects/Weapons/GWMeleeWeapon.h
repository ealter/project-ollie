//
//  GWMeleeWeapon.h
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWWeapon.h"
#import "GWGestures.h"

@class HMVectorNode;

@interface GWMeleeWeapon : GWWeapon <GestureChild> {
    b2World         *_world;        //Box2Dworld
    HMVectorNode    *drawNode;      //Draws trajectory to screen
    BOOL            swingRight;     //Keeps track of left/right aim direction

}

//Length of the weapon. Assign in inheriting weapons for accurate swing simulation
@property (assign, nonatomic) float weaponLength; 

//Weapon image.  Easy rotation ensues
@property (strong, nonatomic) CCSprite *meleeImage;

//Huge init, called by individual weapons
-(id)initWithImage:(NSString *)imageName position:(CGPoint) pos size:(CGSize)size ammo:(float) ammo wepLength:(float) length box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

//Calculates the direction of the attack: YES is right, NO is left
-(BOOL)calculateMeleeDirectionFromStart:(CGPoint) startPoint toAimPoint:(CGPoint) aimPoint;

//Uses the HMKVectorNode to draw a trajectory on the screen
-(void)simulateMeleeWithStart:(CGPoint)startPoint Finger:(CGPoint)currPoint;

//Method that applies a force to b2bodies in a certain radius
-(void)applyb2ForceInRadius:(float) maxDistance withStrength:(float)str isOutwards:(BOOL)outwards aimedRight:(BOOL)right;

@end
