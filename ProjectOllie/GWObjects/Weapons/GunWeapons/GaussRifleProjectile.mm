//
//  GaussRifleProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GaussRifleProjectile.h"
#import "GaussRifle.h"


@implementation GaussRifleProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(GAUSS_B_WIDTH, GAUSS_B_HEIGHT) imageName:GAUSS_B_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        gaussTimer = 0;
        self.physicsBody->SetGravityScale(0);
        
        self.emitter = [GWParticleMagicMissile node];
        self.emitter.position = self.position;
        [self.gameWorld addChild:self.emitter];
    }
    
    return self;
}
-(void)update:(ccTime)dt
{
    [self.gameWorld.gameTerrain clipCircle:NO WithRadius:30. x:self.position.x y:self.position.y];
    [self.gameWorld.gameTerrain shapeChanged];
    self.emitter.position = self.position;
    gaussTimer += dt;
    if (gaussTimer >= 4.) {
        [self destroyBullet];
    }
    if (self.bulletCollided && gaussTimer >.05) {
        [self destroyBullet];
    }
}


//YOU SHOULD OVERRIDE THIS OR AT LEAST CALL IT FROM THE CHILD!
-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
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
    gaussTimer = 0;
}

@end
