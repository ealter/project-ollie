//
//  PhysicsSprite.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 1/4/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import "CCSprite.h"

class b2Body;

@interface GWPhysicsSprite : CCSprite {
    b2Body *body_; // strong ref
}

- (void)setPhysicsBody:(b2Body*)body;
- (b2Body*)physicsBody;
- (CGPoint)position;

@end

