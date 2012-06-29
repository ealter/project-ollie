//
//  GWCamera.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/4/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "GWCamera.h"
#import "CGPointExtension.h"
#import "ActionLayer.h"
#import "cocos2d.h"

@interface GWCamera()
{
    CGSize worldDimensions; //dimensions of the world we are observing
    float actionCount;      //helps keep track of the duration of action
    float targetScale;      //the scale we will zoom to in update
}

+ (BOOL)isCCNodeCameraObject:(id)obj;

/*private functions for callfunc delegate*/
-(void)handleOneFingerMotion:(NSSet*)touches;
-(void)handleTwoFingerMotion:(NSSet*)touches;
-(void)twoFingerPan:(NSSet*)touches;
-(void)twoFingerZoom:(NSSet*)touches;
-(void)updateBounds;
-(void)checkBounds;
-(void)updateZoom;
-(void)followTarget;
-(void)handleShakeEffect:(float)dt;

/*private helper functions*/
-(void)createShakeEffect:(float)dt;

@end

@implementation GWCamera

//properties for everyone to see/change
@synthesize isChanging      = _isChanging;
@synthesize target          = _target;
@synthesize actionIntensity = _actionIntensity;
@synthesize maximumScale    = _maximumScale;
@synthesize minimumScale    = _minimumScale;
@synthesize defaultScale    = _defaultScale;
@synthesize children        = _children;

-(id)initWithSubject:(CCNode *)subject worldDimensions:(CGSize)wd{
    if(self = [super init]) {
        //private variables
        subject_        = subject;
        worldDimensions = wd;
        actionCount     = 0;
        targetScale     = 1.f;
        
        //public properties
        self.target          = nil;
        self.isChanging      = NO;
        self.actionIntensity = 0.f;
        self.maximumScale    = 6.f;
        self.minimumScale    = 1.f;
        self.defaultScale    = 1.f;
        self.children        = [NSMutableArray array];
    }
    return self;
}

+ (BOOL)isCCNodeCameraObject:(id)obj
{
    return [obj conformsToProtocol:@protocol(CameraObject)] && [obj isKindOfClass:[CCNode class]];
}

-(void)followNode:(CCNode *)focused{
    //creates a sequence of events that signals change
    //starts following a new node
    //and signals an end of change once the new node is followed
    targetScale = 3.f;
    self.isChanging = YES;
    self.target = focused;
}

-(void)setSubject:(CCNode *)sub{
    subject_ = sub;
}

-(void)revert{
    //sets specific case of changing, but with no target
    targetScale = self.defaultScale;
    self.target = nil;
    self.isChanging = YES; 
}

-(void)panBy:(CGPoint)diff{
    CGPoint oldPos = subject_.position;
    CGPoint newPos = ccpAdd(oldPos,diff);
    [subject_ setPosition:newPos];
    
    for (CCNode<CameraObject> *child in self.children) {
        if(![[self class] isCCNodeCameraObject:child]) continue;
        CGPoint tdiff = ccpMult(diff, [child getParallaxRatio]);
        CGPoint oldPos = child.position;
        [child setPosition:ccpAdd(oldPos,tdiff)];
    }
}

-(void)panTo:(CGPoint)dest{
    [subject_ setPosition:dest];
}

-(void)zoomBy:(float)diff withAverageCurrentPosition:(CGPoint)currentPosition {
    CGPoint utCurrentPosition = currentPosition;
    currentPosition = [subject_ convertToNodeSpace:currentPosition];
    
    //calculate the old centerpoint
    CGPoint oldCenterPoint = ccpMult(currentPosition,subject_.scale);
    
    // Set the scale.
    float scale = subject_.scale;
    float newScale = max(self.minimumScale, min(scale*diff, self.maximumScale));
    [subject_ setScale: newScale];

    // Get the new center point.
    CGPoint newCenterPoint = ccpMult(currentPosition, subject_.scale);

    // Then calculate the delta.
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);

    // Now adjust the layer by the delta.
    //[self panBy:centerPointDelta];
    [subject_ setPosition:ccpAdd(subject_.position,centerPointDelta)];
    
    for (CCNode<CameraObject> *child in self.children) {
        if(![[self class] isCCNodeCameraObject:child]) continue;
        
        CGPoint tempPosition = [subject_ convertToNodeSpace:utCurrentPosition];
        
        CGPoint oldCenterPoint = ccpMult(tempPosition,child.scale);
        float scaleDiff = (newScale - scale)*([child getParallaxRatio]);
        float tempNewScale = child.scale+scaleDiff;
        
        child.scale = tempNewScale;
        
        // Get the new center point.
        CGPoint newCenterPoint = ccpMult(tempPosition,child.scale);
        
        // Then calculate the delta.
        CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);
        [child setPosition:ccpAdd(child.position, centerPointDelta)];
    }
}

-(void)createShakeEffect:(float)dt{
    //the shakeRate will determine the weight given to dt
    float shakeRate = 55;
    actionCount+=dt*shakeRate;
    
    //modulo the total action count around 360 degrees
    actionCount = fmod(actionCount, 360.f);

    float currentDegree = self.actionIntensity * sin(actionCount);
    
    //set rotation
    CCNode* parent = [subject_ parent];
    parent.rotation = currentDegree;
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
    [self updateZoom];
    [self updateBounds];
    [self handleShakeEffect:dt];
    [self followTarget];
}

-(void)touchesBegan:(NSSet *)touches{
    if([touches count] == 2) {
        UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
        UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
        
        CGPoint touchLocation1 = [touch1 locationInView: [touch1 view]];
        touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
        touchLocation1 = [self->subject_ convertToNodeSpace:touchLocation1];
        
        CGPoint touchLocation2 = [touch2 locationInView: [touch2 view]];
        touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
        touchLocation2 = [self->subject_ convertToNodeSpace:touchLocation2];
    }
}

-(void)touchesMoved:(NSSet *)touches{
    if([touches count] == 1)
        [self handleOneFingerMotion:touches];
    if([touches count] == 2)
        [self handleTwoFingerMotion:touches];

}

-(void)touchesEnded:(NSSet *)touches{

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
        
        
        self.target = nil;
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
        
        //pans from motion
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
    
    
    self.target = nil;
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

/*PRIVATE HELPER FUNCTIONS FOR UPDATING CAMERA*/

-(void)updateBounds{
    
    if(self.target == nil)
    {
        [self checkBounds];
    }
}

-(void)checkBounds{
    //elastic borders
    CGPoint worldPos =  subject_.position;
    CGPoint newPos = ccp(0,0);
    //left border
    if(worldPos.x > 0)
    {
        float offset = -worldPos.x;
        float elasticity = .15f;
        newPos = ccp(offset * elasticity,0); 
        [self panBy:newPos];

    }
    //right border
    else if(worldPos.x-subject_.contentSize.width < -subject_.contentSize.width*subject_.scale)
    {
        float offset = -(worldPos.x-subject_.contentSize.width) - subject_.contentSize.width*subject_.scale;
        float elasticity = .15f;
        newPos = ccp(offset * elasticity,0);
        [self panBy:newPos];

    }
    //bottom border
    if(worldPos.y > 0)
    {
        float offset = -worldPos.y;
        float elasticity = .15f;
        newPos = ccp(0,offset * elasticity);
        [self panBy:newPos];

    }
    //top border
    else if(worldPos.y-subject_.contentSize.height < -subject_.contentSize.height*subject_.scale)
    {
        float offset = -(worldPos.y-subject_.contentSize.height) - subject_.contentSize.height*subject_.scale;
        float elasticity = .15f;
        newPos = ccp(0,offset * elasticity);
        [self panBy:newPos];

    }

}

-(void)handleShakeEffect:(float)dt{
    //shake effect
    if(self.actionIntensity < .1f) {
        self.actionIntensity = 0;
        CCNode* parent = [subject_ parent];
        parent.rotation = 0;
        actionCount = 0;
    }
    else {
        [self createShakeEffect:dt];
        
        //decrease intensity
        self.actionIntensity = self.actionIntensity*.93f;
    }
}

-(void)updateZoom{
    
    //adjust zoom to be at target scale
    //if in process of reverting, only time it is changing without a target
    if(self.isChanging && self.target == nil)
    {
        if(subject_.scale > self.defaultScale)
        {
            float diff = subject_.scale - self.defaultScale;
            [self zoomBy:.9f withAverageCurrentPosition:[subject_ convertToNodeSpace:ccp(subject_.contentSize.width/2,subject_.contentSize.height/2)]];
            if(diff*diff < .01)
                self.isChanging = NO;
        }
    }
    else if(self.target != nil){
        //adjust scale to match the desired scale
        float scaleDiff = targetScale - subject_.scale;
        float zoomMultiplier = 0;
        if(scaleDiff < 0) 
            zoomMultiplier = .9f;
        else {
            zoomMultiplier = 1.1f;
        }
        if(scaleDiff*scaleDiff > .01f)
            [self zoomBy:zoomMultiplier withAverageCurrentPosition: self.target.position];
    }
}

-(void)followTarget{
    if(self.target != nil)
    {
        CGPoint moveVec;
        CCNode *n = subject_;
        CCNode *p = [subject_ parent];
        CGPoint halfScreenSize = ccp(subject_.contentSize.width/2.f,subject_.contentSize.height/2.f);
        CGPoint p1 = ccpMult(halfScreenSize, 1.f/p.scale);
        CGPoint p2 = ccpMult(self.target.position, n.scale);
        CGPoint destination = ccpSub(p1,p2);
        
        //using correctly calculated destination, normalize distance
        //and move a given percentage of that distance per update
        //until the distance is subpixel
        moveVec = ccpSub(destination, n.position);
        moveVec = ccpMult(moveVec,.1f);
        [self panBy:moveVec];
    }
}
@end
