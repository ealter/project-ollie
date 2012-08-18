//
//  FlaskProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FlaskProjectile.h"
#import "Flask.h"
#import "FlaskChemical.h"
#import "GameConstants.h"
#import "GWParticles.h"

@implementation FlaskProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [super initWithBulletSize:CGSizeMake(FLASK_WIDTH*PTM_RATIO, FLASK_HEIGHT*PTM_RATIO) imageName:FLASK_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        destroyTimer = 0;
        didCollide   = FALSE;
    }
    
    return self;
}

-(void)makeChemicals
{
    for (int i = -NUM_CHEMICALS/2; i < NUM_CHEMICALS/2; i++) {
        GWProjectile *thrown   = [[FlaskChemical alloc] initWithStartPosition:self.position b2World:_world gameWorld:self.gameWorld];
        [self.gameWorld addChild:thrown];
        
        thrown.physicsBody->SetLinearVelocity(b2Vec2(2.*i/NUM_CHEMICALS, .03));
    }
}

-(void)update:(ccTime)dt
{
    destroyTimer += dt;
    if (destroyTimer >= self.fuseTimer) {
        [self destroyBullet];
    }
    if (didCollide) {
        [self makeChemicals];
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
    if (destroyTimer > 0.2) {
        didCollide  = TRUE;
    }
}

@end
