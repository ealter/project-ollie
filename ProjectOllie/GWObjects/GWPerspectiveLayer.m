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

@synthesize camera = _camera;
@synthesize z = _z;


- (id) initWithCamera:(GWCamera*)camera z:(float)z
{
    if (self = [super init])
    {
        _camera = camera;
        _z = z;
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
    float projectionScale = _camera.z0/(_camera.location.z - _z);
    //printf("\n_z: %f, scale %f\n", _z, projectionScale);
    float x = (position_.x - _camera.location.x)*projectionScale+_camera.center.x;
    float y = (position_.y - _camera.location.y)*projectionScale+_camera.center.y;
    
    if ( ignoreAnchorPointForPosition_ ) {
        x += anchorPointInPoints_.x;
        y += anchorPointInPoints_.y;
    }
    
    // Make matrix
    float radians = _camera.angle;
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
