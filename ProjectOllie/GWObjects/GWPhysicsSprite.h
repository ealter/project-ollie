//
//  PhysicsSprite.h
//  cocos2d-ios
//
//  Created by the lion den on 5/31/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//
//  Defines trackable physics sprites

#import "CCSprite.h"

class b2Body;

@interface GWPhysicsSprite : CCSprite {
    b2Body *body_; // strong ref
}

- (void)setPhysicsBody:(b2Body*)body;
- (b2Body*)physicsBody;
- (CGPoint)position;

@end

