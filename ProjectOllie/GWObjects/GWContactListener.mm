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

}

void GWContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
    handleCharacterContacts(contact, impulse);
    
    
}

void GWContactListener::handleCharacterContacts(b2Contact* contact,  const b2ContactImpulse* impulse){
    /************************
     * Character Collisions *
     ************************/
    
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    
    b2Filter filterA = fixtureA->GetFilterData();
    b2Filter filterB = fixtureB->GetFilterData();
    
    GWCharacter* character;
    b2Fixture* charFixture;
    
    if(filterA.maskBits == MASK_BONES && filterB.maskBits != MASK_TERRAIN)
        charFixture = fixtureA;
    else if (filterA.maskBits != MASK_TERRAIN && filterB.maskBits == MASK_BONES)
        charFixture = fixtureB;
    if(charFixture)
    {
        character = (__bridge GWCharacter*)charFixture->GetBody()->GetUserData();
        if(charFixture->GetBody()->GetLinearVelocity().LengthSquared() > 1.)
            character.state = kStateRagdoll;
    }
}

