//
//  GWPerspectiveLayer.m
//  ProjectOllie
//
//  Created by Steve Gregory on 8/3/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "GWPerspectiveLayer.h"
#import "GWCamera.h"
#import "CCDirector.h"

@implementation GWPerspectiveLayer

@synthesize camera = _camera;
@synthesize z = _z;
@synthesize bufferedDrawing = _bufferedDrawing;


- (id) initWithCamera:(GWCamera*)camera z:(float)z
{
    if (self = [super init])
    {
        CGSize s = [[CCDirector sharedDirector] winSizeInPixels];
        self.camera          = camera;
        self.z               = z;
        self.bufferedDrawing = [CCRenderTexture renderTextureWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        

        
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

// Overrides node transform, uses camera
-(CGAffineTransform) nodeToParentTransform
{
    if (!camera_)
    {
        //printf("No camera set to transform GWPerspective Layer");
        //return transform_;
    }
    
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


- (void) collectShadow:(CCRenderTexture *)shadowMap
{
    CCLOG(@"The bufferedrawing is %p",self.bufferedDrawing);
    //Render to the buffer, (do what visit would typically do)
    [self.bufferedDrawing beginWithClear:0 g:0 b:0 a:0];
    [super visit];
    [shadowMap visit];
    [_bufferedDrawing end];
    
    //Add shadow of this layer to the map
    [shadowMap begin];
    [self.bufferedDrawing visit];
    [shadowMap end];
}

- (void) visit
{
    
 //   CCLOG(@"The buffered drawing is %p",self.bufferedDrawing);
    //Draw the buffered rendering
    [self.bufferedDrawing visit];
    
}

@end
