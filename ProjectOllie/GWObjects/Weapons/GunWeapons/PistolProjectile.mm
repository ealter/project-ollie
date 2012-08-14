//
//  PistolProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 8/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PistolProjectile.h"
#import "Pistol.h"
#import "GWParticles.h"


@implementation PistolProjectile


-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(PISTOL_B_WIDTH, PISTOL_B_HEIGHT) imageName:PISTOL_B_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        self.physicsBody->SetGravityScale(0);
    }
    
    return self;
}
-(void)update:(ccTime)dt
{
    if (self.bulletCollided) {
        [self destroyBullet];
    }
}

-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:15. x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
    }
    
    //Clean up bullet and remove from parent
    
    [[self gameWorld] removeChild:self.emitter cleanup:YES];
    _world->DestroyBody(self.physicsBody);
    [[self parent] removeChild:self cleanup:YES];    
}


//This method is called by the contact listener, and should be overridden by any bullets inheriting from the 
//class (but not by thrown weapons, which will use a fuse time)
-(void)bulletContact
{
    self.bulletCollided = TRUE;
}


@end
