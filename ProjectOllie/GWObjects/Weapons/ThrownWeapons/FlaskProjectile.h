//
//  FlaskProjectile.h
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWProjectile.h"

@interface FlaskProjectile : GWProjectile {
    BOOL didCollide;
}

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
