//
//  ShotgunProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShotgunProjectile.h"
#import "Shotgun.h"


@implementation ShotgunProjectile

-(id)initWithStartPosition:(CGPoint)pos b2World:(b2World *)world gameWorld:(ActionLayer *)gWorld
{
    if (self = [self initWithBulletSize:CGSizeMake(SHOTGUN_B_WIDTH, SHOTGUN_B_HEIGHT) imageName:SHOTGUN_B_IMAGE startPosition:pos b2World:world b2Bullet:YES gameWorld:gWorld]) {
        
    }
                
    return self;
}

-(id)initWithBulletSize:(CGSize)size imageName:(NSString *)imageName startPosition:(CGPoint)pos b2World:(b2World *)world b2Bullet:(BOOL)isBullet gameWorld:(ActionLayer *)gWorld
{
    if ((self = [self initWithFile:imageName])) {
        //take the world, speed, and pos
        _world              = world;
        self.gameWorld      = gWorld;
        self.bulletCollided = FALSE;
        
        //Schedule updates
        [self scheduleUpdate];
        
        b2BodyDef bd;
        b2PolygonShape box;
        b2FixtureDef fixtureDef;
        
        //Set up the BodyDef
        bd.type             = b2_dynamicBody;
        bd.linearDamping    = .1f;
        bd.angularDamping   = .1f;
        //bd.bullet           = true;//isBullet;
        
        box.SetAsBox(size.width/2./PTM_RATIO,size.height/2./PTM_RATIO);
        
        fixtureDef.shape    = &box;
        fixtureDef.density  = 1.0f;
        fixtureDef.friction = 0.0f;
        fixtureDef.restitution = 1.0f;
        fixtureDef.filter.categoryBits = CATEGORY_PELLETS;
        fixtureDef.filter.maskBits = MASK_PELLETS;
        b2Body *bulletShape = _world->CreateBody(&bd);
        bulletShape->CreateFixture(&fixtureDef);
        bulletShape->SetTransform(b2Vec2(pos.x/PTM_RATIO,pos.y/PTM_RATIO), 0); 
        
        self.physicsBody = bulletShape;
        if (isBullet) {
            self.physicsBody->SetUserData((__bridge void*)self);
        }
        bulletShape->SetTransform(b2Vec2(self.position.x/PTM_RATIO,self.position.y/PTM_RATIO), 0);   
    }
    
    return self;
}


-(void)update:(ccTime)dt
{
    destroyTimer += dt;
    if (self.bulletCollided || destroyTimer > SHOTGUN_B_LIFE) {
        [self destroyBullet];
    }
}


//YOU SHOULD OVERRIDE THIS OR AT LEAST CALL IT FROM THE CHILD!
-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
        [self.gameWorld.gameTerrain clipCircle:NO WithRadius:15. x:self.position.x y:self.position.y];
        [self.gameWorld.gameTerrain shapeChanged];
    }
    
    //Clean up bullet and remove from parent
    [[self parent] removeChild:self cleanup:YES];  
    _world->DestroyBody(self.physicsBody);
}


//This method is called by the contact listener, and should be overridden by any bullets inheriting from the 
//class (but not by thrown weapons, which will use a fuse time)
-(void)bulletContact
{
    self.bulletCollided = TRUE;//Destroy at the next opportunity
}

@end
