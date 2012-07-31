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
#import "GWProjectile.h"

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
    //handleProjectileContacts(contact, impulse);
    // contact->SetEnabled(handleOneWayLand(contact));
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
    else return;
    
    character = (__bridge GWCharacter*)charFixture->GetBody()->GetUserData();
    if(charFixture->GetBody()->GetLinearVelocity().LengthSquared() > 1.)
        character.state = kStateRagdoll;
    
}

bool GWContactListener::handleOneWayLand(b2Contact *contact)
{
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    
    //check if one of the fixtures is the platform
    b2Fixture* platformFixture = NULL;
    b2Fixture* otherFixture = NULL;
    if ( fixtureA->GetFilterData().maskBits == MASK_TERRAIN ) {
        platformFixture = fixtureA;
        otherFixture = fixtureB;
    }
    else if ( fixtureB->GetFilterData().maskBits == MASK_TERRAIN  ) {
        platformFixture = fixtureB;
        otherFixture = fixtureA;
    }
    
    if ( !platformFixture )
        return true;
    
    b2WorldManifold worldManifold;
    contact->GetWorldManifold( &worldManifold );
    
    b2EdgeShape* edge    = (b2EdgeShape*)platformFixture->GetShape();
    b2Vec2 average       = edge->m_vertex1+edge->m_vertex2;
    average              = b2Vec2(average.x/2.,average.y/2.);
    
    b2Vec2 bodyDisp      = average - otherFixture->GetBody()->GetPosition();
    b2Vec2 parallel      = edge->m_vertex2 - edge->m_vertex1;
    b2Vec2 normalOut     = b2Vec2(-parallel.y, parallel.x);

    if(b2Dot(normalOut, bodyDisp) <= 0)
    {
        return true;
    }
    
    return false;
}

void GWContactListener::handleProjectileContacts(b2Contact* contact,  const b2ContactImpulse* impulse){

    /*********************
     * Bullet Collisions *
     *********************
    
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    
    b2Filter filterA = fixtureA->GetFilterData();
    b2Filter filterB = fixtureB->GetFilterData();
    
    GWProjectile* projectile;
    b2Fixture* projFixture;
    
    if (filterA.maskBits == MASK_PROJECTILES) {
        projFixture = fixtureA;
    }else if (filterB.maskBits == MASK_PROJECTILES)
    {
        projFixture = fixtureB;
    }
    if (projFixture) {
        projectile = (__bridge GWProjectile*)projFixture->GetBody()->GetUserData();
        if (projectile) {
            [projectile bulletContact];
        }
    }*/
}

