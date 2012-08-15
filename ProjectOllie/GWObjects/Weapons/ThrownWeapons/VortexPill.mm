//
//  VortexPill.m
//  ProjectOllie
//
//  Created by Lion User on 8/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "VortexPill.h"
#import "VortexPillProjectile.h"
#import "GameConstants.h"
#import "cocos2d.h"


@implementation VortexPill
@synthesize pill1       = _pill1;
@synthesize pill2       = _pill2;
@synthesize pill3       = _pill3;

-(id)initWithPosition:(CGPoint) pos ammo:(float) ammo box2DWorld: (b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithImage:VPILL_IMAGE_1 position:pos size:CGSizeMake(VPILL_WIDTH, VPILL_HEIGHT) ammo:ammo box2DWorld:world fuseTime:4 gameWorld:gWorld]) {
        //add extra sprites for PHAT effects
        self.pill1       = [CCSprite spriteWithFile:VPILL_IMAGE_2];
        self.pill1.position = ccp(VPILL_WIDTH*PTM_RATIO/2, VPILL_HEIGHT*PTM_RATIO/2);
        self.pill2       = [CCSprite spriteWithFile:VPILL_IMAGE_3];
        self.pill2.position = ccp(VPILL_WIDTH*PTM_RATIO/2, VPILL_HEIGHT*PTM_RATIO/2);
        self.pill3       = [CCSprite spriteWithFile:VPILL_IMAGE_4];
        self.pill3.position = ccp(VPILL_WIDTH*PTM_RATIO/2, VPILL_HEIGHT*PTM_RATIO/2);
        
        
        
        [self scheduleUpdate];
        
        //add children
        [self addChild:self.pill3];
        [self addChild:self.pill1];
        [self addChild:self.pill2];
    }
    
    return self;
}

-(void)fillDescription
{
    self.title          = @"Vortex Pill";
    self.description    = @"Swirls with dark energies.  Implodes after 4 seconds, tearing through land and sucking in nearby apes.";
}

-(void)update:(ccTime)dt
{
    spin                += dt;
    self.pill1.rotation += spin*90;
    self.pill2.rotation += spin*180;
    self.pill3.rotation += spin*120;
    DebugLog(@"Spin is: %f", spin);
    
    if (spin > 4) {
        spin =0;
    }
    
}

-(void)throwWeaponWithLocation:(CGPoint)startPoint fromFinger:(CGPoint)endPoint
{
    if (self.ammo >0) {
        //Make a bullet which acts as the thrown item
        thrown              = [[VortexPillProjectile alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
        b2Body* thrownShape = thrown.physicsBody;
        [self.gameWorld addChild:thrown];
        thrown.fuseTimer    = fuseTimer;
        
        //Throw the weapon with calculated velocity
        CGPoint vel         = [self calculateVelocityFromWep:self.holder.position toFinger:endPoint];
        thrownShape->SetLinearVelocity(b2Vec2(vel.x, vel.y));
        
        //Calculate some spin so throw looks better
        float throwSpin = CCRANDOM_0_1();
        throwSpin = throwSpin/20000.;
        if (vel.x < 0) {
            throwSpin = throwSpin * -1.;
        }
        thrownShape->ApplyAngularImpulse(throwSpin);
        
        self.ammo--;
    }else {
        //no more ammo!
    }
}

@end
