//
//  ShotgunProjectile.h
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GWProjectile.h"

@interface ShotgunProjectile : GWProjectile {
    
}


-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *) gWorld;


@end
