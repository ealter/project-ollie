//
//  GWCamera.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/4/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "GWCamera.h"
#import "CCAction.h"
#import "CCActionInterval.h"
#import "CGPointExtension.h"
#import "CCActionInstant.h"
#import "CCActionEase.h"
#import "ActionLayer.h"

@interface GWCamera()
{
    CGSize worldDimensions; //dimensions of the world we are observing
    float actionCount;      //helps keep track of the duration of action
}

/*private functions for callfunc delegate*/
-(void)beginMotion;
-(void)endMotion;
-(void)followDel;
-(void)stopActions;
-(void)handleOneFingerMotion:(NSSet*)touches;
-(void)handleTwoFingerMotion:(NSSet*)touches;
-(void)twoFingerPan:(NSSet*)touches;
-(void)twoFingerZoom:(NSSet*)touches;

/*private helper functions*/
-(void)createShakeEffect:(float)dt;

@end

@implementation GWCamera

//properties for everyone to see/change
@synthesize isChanging      = _isChanging;
@synthesize target          = _target;
@synthesize actionIntensity = _actionIntensity;
@synthesize zoomOrigin      = _zoomOrigin;
@synthesize maximumScale    = _maximumScale;
@synthesize minimumScale    = _minimumScale;
@synthesize defaultScale    = _defaultScale;

-(id)initWithSubject:(CCNode *)subject worldDimensions:(CGSize)wd{
    if(( self = [super init] ))
    {
        self->subject_ = subject;
        self.target = self->subject_;
        self.isChanging = NO;
        self->worldDimensions = wd;
        self.actionIntensity = 0;
        self->actionCount = 0;
        self.zoomOrigin = ccp(0,0);
        self.maximumScale = 6.f;
        self.minimumScale = 1.f;
        self.defaultScale = 1.f;

    }
    return self;
}

-(void)followNode:(CCNode *)focused{
    //creates a sequence of events that signals change
    //starts following a new node
    //and signals an end of change once the new node is followed
    
    //stop all previous actions
    [self stopActions];
    self.target = focused;
    id bMotion = [CCCallFunc actionWithTarget:self selector:@selector(beginMotion)];
    id follow  = [CCCallFunc actionWithTarget:self selector:@selector(followDel)];
    id moveFollow = [CCSequence actions:bMotion,follow,nil];
    [self->subject_ runAction:[CCScaleTo actionWithDuration:.95f scale:3.f]];
    [self->subject_ runAction:moveFollow];
}

-(void)revert{
    //sets specific case of changing, but with no target
    [self stopActions];
    self.isChanging = YES; 
}

-(void)panBy:(CGPoint)diff{
    [self stopActions];
    CGPoint oldPos = self->subject_.position;
    CGPoint newPos = ccpAdd(oldPos,diff);
    [self->subject_ setPosition:newPos];
}

-(void)panTo:(CGPoint)dest{
    [self stopActions];
    [self->subject_ setPosition:dest];
}

-(void)zoomBy:(float)diff withAverageCurrentPosition:(CGPoint)currentPosition{
    [self stopActions];
    
    //calculate the old centerpoint
    CGPoint oldCenterPoint = ccpMult(currentPosition,subject_.scale);
    
    // Set the scale.
    float scale = self->subject_.scale;
    float newScale = max(self.minimumScale,min(scale*diff, self.maximumScale));
    [self->subject_ setScale: newScale];

    // Get the new center point.
    CGPoint newCenterPoint = ccpMult(currentPosition,subject_.scale);

    // Then calculate the delta.
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);

    // Now adjust the layer by the delta.
    [self panBy:centerPointDelta];

   

}

-(void)createShakeEffect:(float)dt{
    //the shakeRate will determine the weight given to dt
    float shakeRate = 60;
    actionCount+=dt*shakeRate;
    
    //modulo the total action count around 360 degrees
    actionCount = fmod(actionCount,360.f);
    float currentDegree = self.actionIntensity * sin(actionCount);
    
    //set rotation
    self->subject_.rotation = currentDegree;
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
    
    //elastic borders
    CGPoint worldPos = subject_.position;
    //left border
    if(worldPos.x > 0)
    {
        float offset = -worldPos.x;
        float elasticity = .15f;
        [subject_ setPosition:ccpAdd(subject_.position,ccp(offset * elasticity,0))];
    }
    //right border
    else if(worldPos.x-subject_.contentSize.width < -subject_.contentSize.width*subject_.scale)
    {
        float offset = -(worldPos.x-subject_.contentSize.width) - subject_.contentSize.width*subject_.scale;
        float elasticity = .15f;
        [subject_ setPosition:ccpAdd(subject_.position,ccp(offset * elasticity,0))];
    }
    //bottom border
    if(worldPos.y > 0)
    {
        float offset = -worldPos.y;
        float elasticity = .15f;
        [subject_ setPosition:ccpAdd(subject_.position,ccp(0,offset * elasticity))];
    }
   //top border
    else if(worldPos.y-subject_.contentSize.height < -subject_.contentSize.height*subject_.scale)
    {
        float offset = -(worldPos.y-subject_.contentSize.height) - subject_.contentSize.height*subject_.scale;
        float elasticity = .15f;
        [subject_ setPosition:ccpAdd(subject_.position,ccp(0,offset * elasticity))];
    }
    
    
    //shake effect
    if(self.actionIntensity < .1f) {
        self.actionIntensity = 0;
        self->subject_.rotation = 0;
        actionCount = 0;
    }
    else {
        [self createShakeEffect:dt];
        
        //decrease intensity
        self.actionIntensity = self.actionIntensity*.87f;
    }
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
        [self panBy:diff];
    }
}

-(void)handleTwoFingerMotion:(NSSet *)touches{
    /**
     * Uses pinch to zoom and scrolling simultaneously
     */
    
    //moves from motion
    [self twoFingerPan:touches];
    
    //pans from motion
    [self twoFingerZoom:touches];
    
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
    
    [self panBy:ccpSub(averageCurrentPosition,averageLastPosition)];
}

-(void)twoFingerZoom:(NSSet *)touches{
    /* ZOOMING */
    
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

    touchLocation2 = [self->subject_ convertToNodeSpace:touchLocation2];
    prevLocation2 = [self->subject_ convertToNodeSpace:prevLocation2];
    touchLocation1 = [self->subject_ convertToNodeSpace:touchLocation1];
    prevLocation1 = [self->subject_ convertToNodeSpace:prevLocation1];
    
    CGPoint averageCurrentPosition = ccpMult(ccpAdd(touchLocation1,touchLocation2),.5f);
    
    
    //find the new scale
    float difScale = 
    ccpLength(ccpSub(touchLocation1,touchLocation2))/ccpLength(ccpSub(prevLocation1,prevLocation2));
    
   
    [self zoomBy:difScale withAverageCurrentPosition:averageCurrentPosition];
    


    
}

/*PRIVATE HELPER FUNCTIONS FOR DELEGATES*/
-(void)followDel{
    [self->subject_ runAction:[CCFollow actionWithTarget:self.target]];
}

-(void)beginMotion{
    self.isChanging = YES;
}

-(void)endMotion{
    self.isChanging = NO;
}
-(void)stopActions{
    [self->subject_ stopAllActions];
    self.target = nil;
}

@end
