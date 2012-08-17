//
//  GWPerspectiveLayer.m
//  ProjectOllie
//
//  Created by Steve Gregory on 8/3/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "GWPerspectiveLayer.h"
#import "GWCamera.h"

@implementation GWPerspectiveLayer

@synthesize gwCamera = _gwCamera;
@synthesize z = _z;


- (id) initWithCamera:(GWCamera*)gwCamera z:(float)z
{
    if (self = [super init])
    {
        _gwCamera = gwCamera;
        _z = z;
        
        // rotate around center of layer
        self.anchorPoint = CGPointMake(.5f,.5f);
        [self setIgnoreAnchorPointForPosition:YES];
    }
    return self;
}

// Ensures nodeToParentTransform is called
-(BOOL) dirty
{
    return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
    
    //Project position to the camera point onto the screen plane
    float projectionScale = _gwCamera.z0/(_gwCamera.location.z - _z);
    //printf("\n_z: %f, scale %f\n", _z, projectionScale);
    float x = (position_.x - _gwCamera.location.x)*projectionScale+_gwCamera.center.x;
    float y = (position_.y - _gwCamera.location.y)*projectionScale+_gwCamera.center.y;
    
    if ( ignoreAnchorPointForPosition_ ) {
        x += anchorPointInPoints_.x;
        y += anchorPointInPoints_.y;
    }
    
    // Make matrix
    float radians = _gwCamera.angle;
    float c = cosf(radians);
    float s = sinf(radians);
    
    if(!CGPointEqualToPoint(anchorPointInPoints_, CGPointZero)) {
        x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
        y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
    }
    
    // Rot, Translate Matrix
    float sx = scaleX_ *projectionScale;
    float sy = scaleY_ *projectionScale;
    transform_ = CGAffineTransformMake( c*sx,  s*sx,
                                       -s*sy,  c*sy,
                                       x,  y );
    
    return transform_;
}

@end
