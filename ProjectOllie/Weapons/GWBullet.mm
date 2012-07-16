//
//  GWBullet.m
//  ProjectOllie
//
//  Created by Lion User on 7/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWBullet.h"
#import "Box2D.h"
@interface GWBullet ()

//Box2D body
@property (assign, nonatomic) b2Body *box2DBody;

//Projectile Speed
@property (assign, nonatomic) float bulletSpeed;

//Bullet Sprite
@property (strong, nonatomic) CCSprite *bulletSprite;

//Method for firing bullet
-(void)fireBullet:(CGPoint) target;

@end	



@implementation GWBullet
@synthesize box2DBody       = _box2Dbody;
@synthesize bulletSpeed     = _bulletSpeed;
@synthesize bulletSprite    = _bulletSprite;

-(id)init
{
    if (self = [super init]) {
        
        /* Tie to box2d 
        b2BodyDef bd;
        b2PolygonShape box;
        b2FixtureDef fixtureDef;
        b2RevoluteJointDef jointDef;
        
        // Body definition 
        bd.type = b2_dynamicBody;
        bd.gravityScale = 1.;
        bd.linearDamping = .1f;
        bd.angularDamping = .1f;
        
        box.SetAsBox(root->l/PTM_RATIO/2.f,root->w/PTM_RATIO/2.);
        fixtureDef.shape = &box;
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.4f;
        fixtureDef.restitution = 0.1f;
        fixtureDef.filter.categoryBits = CATEGORY_BONES;
        fixtureDef.filter.maskBits = MASK_BONES;
        bd.position.Set(root->x/PTM_RATIO, root->y/PTM_RATIO);
        b2Body *boneShape = world->CreateBody(&bd);
        boneShape->CreateFixture(&fixtureDef);
        
        //TURN OFF FOR RAGDOLL EFFECT
        root->box2DBody = boneShape;
        
        boneShape->SetTransform(boneShape->GetPosition(), root->a);*/
        
        
    }
    
    return self;
}

-(void)fireBullet:(CGPoint)target
{
    
}

@end
