//
//  Flask.h
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWThrownWeapon.h"

#define FLASK_WIDTH (20./PTM_RATIO)
#define FLASK_HEIGHT (25./PTM_RATIO)
#define FLASK_IMAGE @"flask.png"
#define NUM_CHEMICALS 12.

@interface Flask : GWThrownWeapon {
    
}

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *) gWorld;

@end
