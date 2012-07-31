 //
//  GWBullet.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWBullet.h"
#import "GameConstants.h"
#import "Box2D.h"

@implementation GWBullet
@synthesize  gameWorld      = _gameWorld;

-(id)initWithBulletSize:(CGSize)size imageName:(NSString *)imageName startPosition:(CGPoint)pos b2World:(b2World *)world b2Bullet:(BOOL)isBullet gameWorld:(ActionLayer *)gWorld
{
    if ((self = [self initWithFile:imageName])) {
        //take the world, speed, and pos
        _world              = world;
        self.gameWorld      = gWorld;
        b2BodyDef bd;
        b2PolygonShape box;
        b2FixtureDef fixtureDef;
        
        //Set up the BodyDef
        bd.type             = b2_dynamicBody;
        bd.linearDamping    = .1f;
        bd.angularDamping   = .1f;
        bd.bullet           = YES;//isBullet;
        
        box.SetAsBox(size.width/2./PTM_RATIO,size.height/2./PTM_RATIO);
        
        fixtureDef.shape    = &box;
        fixtureDef.density  = 1.0f;
        fixtureDef.friction = 0.4f;
        fixtureDef.restitution = 0.1f;
        fixtureDef.filter.categoryBits = CATEGORY_PROJECTILES;
        fixtureDef.filter.maskBits = MASK_PROJECTILES;
        b2Body *bulletShape = _world->CreateBody(&bd);
        bulletShape->CreateFixture(&fixtureDef);
        bulletShape->SetTransform(b2Vec2(pos.x/PTM_RATIO,pos.y/PTM_RATIO), 0); 
        
        self.physicsBody = bulletShape;
        bulletShape->SetTransform(b2Vec2(self.position.x/PTM_RATIO,self.position.y/PTM_RATIO), 0);   
    }
    
    return self;
}


//YOU SHOULD OVERRIDE THIS OR AT LEAST CALL IT FROM THE CHILD!
-(void)destroyBullet
{
    if(self.gameWorld != NULL)
    {
        //do stuff to the world
    }
    
    //Clean up bullet and remove from parent
    _world->DestroyBody(self.physicsBody);
    [[self parent] removeChild:self cleanup:YES];    
}

@end
