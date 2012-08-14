//
//  BoStaff.m
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BoStaff.h"
#import "GameConstants.h"

@implementation BoStaff

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:BOSTAFF_IMAGE position:pos size:CGSizeMake(BOSTAFF_WIDTH, BOSTAFF_HEIGHT) ammo:ammo wepLength:BOSTAFF_HEIGHT box2DWorld:world gameWorld:gWorld]) {
        
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Bo Staff";
    self.description    = @"A sturdy staff, great for whacking apes around.  Donatello would be proud.";
}

-(void)fireWeapon:(CGPoint)aimPoint
{
    if (self.ammo >0) {        
        if (swingRight) {
            [self applyb2ForceInRadius:self.weaponLength/PTM_RATIO withStrength:0.1 isOutwards:YES aimedRight:YES];
        }else {
            [self applyb2ForceInRadius:self.weaponLength/PTM_RATIO withStrength:0.1 isOutwards:YES aimedRight:NO];
        }
        // decrement ammo
        self.ammo--;
    }else {
        //Out of ammo!
    }
}
                
@end
