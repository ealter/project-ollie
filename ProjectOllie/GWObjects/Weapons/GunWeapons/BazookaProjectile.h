//
//  BazookaProjectile.h
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWProjectile.h"

@interface BazookaProjectile : GWProjectile {
    
}

@property (assign, nonatomic) float accX;

@property (assign, nonatomic) float accY;

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld;


@end
