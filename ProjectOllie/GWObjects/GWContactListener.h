//
//  GWCharacterContactListener.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/29/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#ifndef ProjectOllie_GWCharacterContactListener_h
#define ProjectOllie_GWCharacterContactListener_h

//
//  MyContactListener.h
//  Box2DPong
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "Box2D.h"
#import <algorithm>

@class GWCharacter;

class GWContactListener : public b2ContactListener {
    
public:
    GWContactListener();
    ~GWContactListener();
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
private:
    void handleCharacterContacts(b2Contact* contact);
    void handleProjectileContacts(b2Contact* contact);
    bool handleOneWayLand(b2Contact* contact);
    
};


#endif
