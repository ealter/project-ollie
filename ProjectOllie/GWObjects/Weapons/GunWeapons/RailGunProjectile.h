//
//  RailGunProjectile.h
//  ProjectOllie
//
//  Created by Lion User on 8/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWProjectile.h"

@interface RailGunProjectile : GWProjectile {
    
}

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
