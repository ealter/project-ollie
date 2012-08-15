//
//  VortexPillProjectile.h
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWProjectile.h"

@interface VortexPillProjectile : GWProjectile {
    float spin;
    BOOL vortex;
    BOOL hasClipped;
    CGPoint stayHere;
}

//Extra sprites for effect
@property (strong, nonatomic) CCSprite *pill1;
@property (strong, nonatomic) CCSprite *pill2;
@property (strong, nonatomic) CCSprite *pill3;

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
