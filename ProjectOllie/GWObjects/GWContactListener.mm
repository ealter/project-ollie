//
//  GWContactListener.cpp
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/29/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#import "GWContactListener.h"
#import "GWCharacter.h"
#import "GameConstants.h"

GWContactListener::GWContactListener() {

}

GWContactListener::~GWContactListener() {
}

void GWContactListener::BeginContact(b2Contact* contact) {
    
}

void GWContactListener::EndContact(b2Contact* contact) {

}

void GWContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {

    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    
    b2Filter filterA = fixtureA->GetFilterData();
    b2Filter filterB = fixtureB->GetFilterData();
    
    GWCharacter* character;
    if(filterA.maskBits == MASK_BONES && filterB.maskBits != MASK_TERRAIN)
    {
       // printf("THERE IS SOME CONTAC");
        character = (__bridge GWCharacter*)fixtureA->GetBody()->GetUserData();
        if(fixtureB->GetBody()->GetLinearVelocity().LengthSquared() > 2.)
            character.state = kStateRagdoll;
    }
    else if (filterA.maskBits != MASK_TERRAIN && filterB.maskBits == MASK_BONES)
    {
        //printf("THERE IS SOME CONTAC");
        character = (__bridge GWCharacter*)fixtureB->GetBody()->GetUserData();
        if(fixtureB->GetBody()->GetLinearVelocity().LengthSquared() > 2.)
            character.state = kStateRagdoll;
        
    }
    

}

void GWContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}

