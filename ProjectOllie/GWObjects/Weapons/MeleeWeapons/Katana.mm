//
//  Katana.m
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Katana.h"
#import "GameConstants.h"

@implementation Katana
-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:KATANA_IMAGE position:pos size:CGSizeMake(KATANA_WIDTH, KATANA_HEIGHT) ammo:ammo wepLength:KATANA_HEIGHT box2DWorld:world gameWorld:gWorld]) {
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Katana";
    self.description    = @"Incredibly lethal sword.  Does great damage with small knockback.";
    self.type           = kType2HMelee;
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {        
        [self applyb2ForceInRadius:self.weaponLength/PTM_RATIO withStrength:0.1 isOutwards:YES aimedRight:swingRight];
        // decrement ammo
        self.ammo--;
    }else {
        //Out of ammo!
    }
}

@end
