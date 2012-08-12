 //
//  GWProjectile.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWProjectile.h"
#import "GameConstants.h"
#import "Box2D.h"
#import "GWCharacterAvatar.h"

@implementation GWProjectile
@synthesize  gameWorld      = _gameWorld;
@synthesize bulletCollided  = _bulletCollided;
@synthesize emitter         = _emitter;
@synthesize fuseTimer       = _fuseTimer;

-(id)initWithBulletSize:(CGSize)size imageName:(NSString *)imageName startPosition:(CGPoint)pos b2World:(b2World *)world b2Bullet:(BOOL)isBullet gameWorld:(ActionLayer *)gWorld
{
    if ((self = [self initWithFile:imageName])) {
        //take the world, speed, and pos
        _world              = world;
        self.gameWorld      = gWorld;
        self.bulletCollided = FALSE;
        self.emitter        = nil;
        destroyTimer        = 0.;
        
        //Schedule updates
        [self scheduleUpdate];
        
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
        if (isBullet) {
            self.physicsBody->SetUserData((__bridge void*)self);
        }
        bulletShape->SetTransform(b2Vec2(self.position.x/PTM_RATIO,self.position.y/PTM_RATIO), 0);   
    }
    
    return self;
}

-(void)applyb2ForceInRadius:(float)maxDistance withStrength:(float)str isOutwards:(BOOL)outwards
{
    b2Vec2 b2ExplosionPosition = b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    
    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		b2Vec2 b2BodyPosition = b->GetPosition();
        
        //See if the body is close enough to apply a force
        float dist = b2Distance(b2ExplosionPosition, b2BodyPosition);
        if (dist > maxDistance) {
            //Too far away! Don't bother.
        }else {
            
            if (b->GetFixtureList()->GetFilterData().maskBits == MASK_BONES) {
                //Its part of a skeleton, set it to ragdoll for cool explosions
                GWCharacterAvatar *tempChar = ((__bridge GWCharacterAvatar *)b->GetUserData());
                tempChar.state = kStateRagdoll;
            }
            
            //Force is away from the center, calculate it and apply to the body
            float strength = (maxDistance - dist) / maxDistance;
            float force = strength * str;
            float angle = atan2f(b2ExplosionPosition.y - b2BodyPosition.y, b2ExplosionPosition.x - b2BodyPosition.x);
            if (outwards) {
                angle = angle + M_PI;
            }
            // Apply an impulse to the body, using the angle
            b->ApplyLinearImpulse(b2Vec2(cosf(angle) * force, sinf(angle) * force), b2BodyPosition);
        }
	}
}

-(void)update:(ccTime)dt
{
    if (self.bulletCollided) {
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
    _world->DestroyBody(self.physicsBody);
    [[self parent] removeChild:self cleanup:YES];    
}


//This method is called by the contact listener, and should be overridden by any bullets inheriting from the 
//class (but not by thrown weapons, which will use a fuse time)
-(void)bulletContact
{
    self.bulletCollided = TRUE;//Destroy at the next opportunity
    
}

@end
