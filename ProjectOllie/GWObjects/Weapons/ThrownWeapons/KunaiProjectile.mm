//
//  KunaiProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 8/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "KunaiProjectile.h"
#import "Kunai.h"
#import "GameConstants.h"
#import "GWParticles.h"

@implementation KunaiProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(KUNAI_WIDTH*PTM_RATIO, KUNAI_HEIGHT*PTM_RATIO) imageName:KUNAI_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        
        destroyTimer = 0;
        self.physicsBody->GetFixtureList()->SetDensity(3.);
        
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    destroyTimer += dt;
    if (destroyTimer >= self.fuseTimer) {
        [self destroyBullet];
    }
}

-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world                        
    }
    
    [super destroyBullet];
}

-(void)bulletContact
{
    
}

@end
