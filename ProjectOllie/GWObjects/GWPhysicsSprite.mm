//
//  PhysicsSprite.mm
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 5/31/12.
//  Copyright hi ku llc 2012. All rights reserved.
//


#import "GWPhysicsSprite.h"
#import "Box2D.h"
#import "GameConstants.h"

@implementation GWPhysicsSprite

-(void) setPhysicsBody:(b2Body *)body
{
    body_ = body;
}

-(b2Body*) physicsBody{
    return body_;
}

// Return yes so that the transform is calculated every frame based on box2d
-(BOOL) dirty
{
    return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{    
    b2Vec2 pos  = body_->GetPosition();
    
    float x = pos.x * PTM_RATIO;
    float y = pos.y * PTM_RATIO;
    
    if ( ignoreAnchorPointForPosition_ ) {
        x += anchorPointInPoints_.x;
        y += anchorPointInPoints_.y;
    }
    
    // Make matrix
    float radians = body_->GetAngle();
    float c = cosf(radians);
    float s = sinf(radians);
    
    if(!CGPointEqualToPoint(anchorPointInPoints_, CGPointZero)) {
        x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
        y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
    }
    
    // Rot, Translate Matrix
    transform_ = CGAffineTransformMake( c,  s,
                                       -s,  c,
                                        x,  y );
    
    return transform_;
}

-(CGPoint)position {
    b2Vec2 pos = body_->GetPosition();
    return CGPointMake(pos.x * PTM_RATIO, pos.y * PTM_RATIO);
}

@end

