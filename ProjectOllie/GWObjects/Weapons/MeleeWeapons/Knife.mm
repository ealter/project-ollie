//
//  Knife.m
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Knife.h"
#import "GameConstants.h"

@implementation Knife
-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:KNIFE_IMAGE position:pos size:CGSizeMake(KNIFE_WIDTH, KNIFE_HEIGHT) ammo:ammo wepLength:KNIFE_HEIGHT box2DWorld:world gameWorld:gWorld]) {
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Knife";
    self.description    = @"CUT EM UP BOIIIIII";
    self.type           = kType1HMelee;
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
