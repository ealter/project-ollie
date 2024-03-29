//
//  GWCamera.m
//  ProjectOllie
//
//  Created by the loudest lion, Sam Zeckendorf, on 6/4/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "GWCamera.h"
#import "CGPointExtension.h"
#import "cocos2d.h"
#import "GameConstants.h"

@interface GWCamera()
{
    CGSize screenDimensions; //dimensions of the screen we have
    float actionCount;       //helps keep track of the duration of action
}

/*private functions for callfunc delegate*/
-(void)handleOneFingerMotion:(NSSet*)touches;
-(void)handleTwoFingerMotion:(NSSet*)touches;
-(void)twoFingerPan:(NSSet*)touches;
-(void)twoFingerZoom:(NSSet*)touches;
-(void)stepTracking;
-(void)handleShakeEffect:(float)dt;
-(void)boundXY;

/*private helper functions*/
-(void)createShakeEffect:(float)dt;

@end

@implementation GWCamera

//properties for everyone to see/change
@synthesize location        = _location;
@synthesize z0              = _z0;
@synthesize zOut            = _zOut;
@synthesize track           = _track;
@synthesize targets         = _targets;
@synthesize actionIntensity = _actionIntensity;
@synthesize center          = _center;
@synthesize angle           = _angle;

-(id)initWithScreenDimensions:(CGSize)sd{
    if(self = [super init]) {
        // Private variables
        screenDimensions = sd;
        actionCount     = 0;
        
        // Caclulate the scale that the layers at z=0 should be when we are zoomed out
        float scaleOut = min(sd.width/(WORLD_WIDTH_PX), sd.height/(WORLD_HEIGHT_PX));
        
        // Public properties
        _location.x          = WORLD_WIDTH_PX/2;
        _location.y          = WORLD_HEIGHT_PX/2;
        self.z0              = -2.5*PTM_RATIO;
        self.zOut            = _z0/scaleOut;
        _location.z          = self.zOut;
        self.track           = NO;
        self.targets         = [NSMutableArray array];
        self.actionIntensity = 0.f;
        _center.x            = sd.width/2;
        _center.y            = sd.height/2;
        _angle               = 0;
        
    }
    return self;
}

-(void)followNode:(CCNode *)focused{
    //creates a sequence of events that signals change
    //starts following a new node
    //and signals an end of change once the new node is followed
    [self.targets addObject:focused];
    self.track  = focused;
    
}

-(void)panBy:(CGPoint)diff{
    
    //Simply move the camera point
    float scale = _location.z/_z0;
    _location.x -= diff.x*scale;
    _location.y -= diff.y*scale;
    
    [self boundXY];
}
	
-(void)zoomBy:(float)diff withAverageCurrentPosition:(CGPoint)currentPosition {
    //Remember the current scale
    float scale = _location.z/_z0;
    
    //Clamp the diff so we can't zoom in more than z0 or out more than zOut
    diff = clampf(diff, _location.z/_z0, _location.z/_zOut);
    
    // Move the thing farther from the layers at z=0 by 1/diff
    _location.z /= diff;
    
    // Lerp the herp towards the center of that zoom
    _location.x += (currentPosition.x-_center.x)*(1-1/diff)*scale;
    _location.y += (currentPosition.y-_center.y)*(1-1/diff)*scale;
    
    [self boundXY];
}

-(void)boundXY
{
    _location.x = clampf(_location.x, 0, PTM_RATIO*(WORLD_WIDTH));
    _location.y = clampf(_location.y, 0, PTM_RATIO*(WORLD_HEIGHT));
}

-(void)createShakeEffect:(float)dt{
    //the shakeRate will determine the weight given to dt
    float shakeRate = 30;
    actionCount+=dt*shakeRate;
    
    _angle = self.actionIntensity * sin(actionCount);
}

-(void)addIntensity:(float)intensity{
    //add intensity to camera (determines shake)
    //but caps it at 50 (as it is degrees of rotation)
    
    self.actionIntensity += intensity;
    if(self.actionIntensity > 50)
        self.actionIntensity = 50;
}

-(void)update:(float)dt{
    //updates camera qualities
    [self stepTracking];
    [self boundXY];
    [self handleShakeEffect:dt];
}

/* PRIVATE GESTURE RECOGNITION */


-(void)handleOneFingerMotion:(NSSet*) touches{
    /**
     * Pans using the location of the finger
     */
    
    for( UITouch *touch in touches ) {
        CGPoint touchLocation = [touch locationInView: [touch view]];
        CGPoint prevLocation  = [touch previousLocationInView: [touch view]];
        
        touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        prevLocation  = [[CCDirector sharedDirector] convertToGL: prevLocation];

        CGPoint diff = ccpSub(touchLocation,prevLocation);
        
        self.track = NO;
        [self panBy:diff];
    }
}

-(void)handleTwoFingerMotion:(NSSet *)touches{
    /**
     * Uses pinch to zoom and scrolling simultaneously
     */
    
    UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
    UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
    
    CGPoint touchLocation1 = [touch1 locationInView: [touch1 view]];
    CGPoint prevLocation1 = [touch1 previousLocationInView: [touch1 view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    prevLocation1 = [[CCDirector sharedDirector] convertToGL: prevLocation1];
    
    CGPoint touchLocation2 = [touch2 locationInView: [touch2 view]];
    CGPoint prevLocation2 = [touch2 previousLocationInView: [touch2 view]];
    touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
    prevLocation2 = [[CCDirector sharedDirector] convertToGL: prevLocation2];
    
    if(ccpLength(ccpSub(touchLocation2,touchLocation1)) > 80)
    {
        //moves from motion
        [self twoFingerPan:touches];
        
        //zooms from motion
        [self twoFingerZoom:touches];
    }
    
}
-(void)twoFingerPan:(NSSet *)touches{
    /* PANNING */

    //create touches
    UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
    UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
    
    CGPoint touchLocation1 = [touch1 locationInView: [touch1 view]];
    CGPoint prevLocation1 = [touch1 previousLocationInView: [touch1 view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    prevLocation1 = [[CCDirector sharedDirector] convertToGL: prevLocation1];
    
    CGPoint touchLocation2 = [touch2 locationInView: [touch2 view]];
    CGPoint prevLocation2 = [touch2 previousLocationInView: [touch2 view]];
    touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
    prevLocation2 = [[CCDirector sharedDirector] convertToGL: prevLocation2];

    CGPoint averageCurrentPosition = ccpMult(ccpAdd(touchLocation1,touchLocation2),.5f);
    CGPoint averageLastPosition    = ccpMult(ccpAdd(prevLocation1,prevLocation2),.5f);
    
    self.track = NO;
    [self panBy:ccpSub(averageCurrentPosition,averageLastPosition)];
}

-(void)twoFingerZoom:(NSSet *)touches{
    /* ZOOMING */
    
    //create touches
    UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
    UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
    
    CGPoint touchLocation1 = [touch1 locationInView: [touch1 view]];
    CGPoint prevLocation1  = [touch1 previousLocationInView: [touch1 view]];
    touchLocation1         = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    prevLocation1          = [[CCDirector sharedDirector] convertToGL: prevLocation1];
    
    CGPoint touchLocation2 = [touch2 locationInView: [touch2 view]];
    CGPoint prevLocation2  = [touch2 previousLocationInView: [touch2 view]];
    touchLocation2         = [[CCDirector sharedDirector] convertToGL: touchLocation2];
    prevLocation2          = [[CCDirector sharedDirector] convertToGL: prevLocation2];
    
    CGPoint averageCurrentPosition = ccpMult(ccpAdd(touchLocation1,touchLocation2),.5f);
    float curLength = ccpLength(ccpSub(touchLocation1,touchLocation2));
    float prevLength = ccpLength(ccpSub(prevLocation1, prevLocation2));
    float difScale = curLength/prevLength;
   
    [self zoomBy:difScale withAverageCurrentPosition:averageCurrentPosition];
}


/*PRIVATE HELPER FUNCTIONS FOR UPDATING CAMERA FUCK YEA AMERICA*/

-(void)handleShakeEffect:(float)dt{
    //shake effect
    if(self.actionIntensity < .01f) {
        self.actionIntensity = 0;
        _angle = 0;
        actionCount = 0;
    }
    else {
        [self createShakeEffect:dt];
        
        //decrease intensity
        self.actionIntensity = self.actionIntensity*.944f;
    }
}

-(void)stepTracking{
    
    // If we are in automatic tracking mode, automatically move camera based on tracked objects
    if(self.track)
    {
        //The location the camera really wants to be deep down inside of its heart
        ccVertex3F targetLocation;
        
        // Nothing being tracked, revert to default camera location
        if ([self.targets count] == 0)
        {
            targetLocation.x = WORLD_WIDTH_PX /2;
            targetLocation.y = WORLD_HEIGHT_PX /2;
            targetLocation.z = _zOut;
        }
        
        //Something is being tracked, center it
        else
        {
            CCNode* target   = [self.targets objectAtIndex:0];
            targetLocation.x = target.position.x;
            targetLocation.y = target.position.y;
            targetLocation.z = _z0;
        }
        
        //Lerpy derpy 40% of the distance towards the target
        _location.x += 0.4f*(targetLocation.x - _location.x);
        _location.y += 0.4f*(targetLocation.y - _location.y);
        _location.z += 0.4f*(targetLocation.z - _location.z);
    }
    
}

- (PanTouchLayer*) createPanTouchLayer
{
    return [[PanTouchLayer alloc] initWithCamera:self];
}

@end


@implementation PanTouchLayer

@synthesize gwCamera = _gwCamera;

- (id) initWithCamera:(GWCamera*)gwCamera
{
    if (self = [super init])
    {
        [super setIsTouchEnabled:YES];
        self.gwCamera = gwCamera;
    }
    return self;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet* allTouches = [event allTouches];
    if([allTouches count] == 1)
        [self.gwCamera handleOneFingerMotion:allTouches];
    else if([allTouches count] == 2)
        [self.gwCamera handleTwoFingerMotion:allTouches];
}

@end
