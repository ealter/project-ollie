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

@interface GWCamera()
{
    CGSize worldDimensions; //dimensions of the world we are observing
    float actionCount;      //helps keep track of the duration of action
    
}

/*private functions for callfunc delegate*/
-(void)beginMotion;
-(void)endMotion;
-(void)followDel;
-(void)handleOneFingerMotion:(NSSet*)touches;
-(void)handleTwoFingerMotion:(NSSet*)touches;

/*private helper functions*/
-(void)createShakeEffect:(float)dt;

@end

@implementation GWCamera

//properties for everyone to see/change
@synthesize isChanging      = _isChanging;
@synthesize target          = _target;
@synthesize actionIntensity = _actionIntensity;
@synthesize zoomOrigin      = _zoomOrigin;

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

    }
    return self;
    
}

-(void)followNode:(CCNode *)focused{
    
    //creates a sequence of events that signals change
    //starts following a new node
    //and signals an end of change once the new node is followed
    
    //stop all previous actions
    [self->subject_ stopAllActions];
    self.target = focused;
    id bMotion = [CCCallFunc actionWithTarget:self selector:@selector(beginMotion)];
    id follow  = [CCCallFunc actionWithTarget:self selector:@selector(followDel)];
    id eMotion = [CCCallFunc actionWithTarget:self selector:@selector(endMotion)];

    id moveFollow = [CCSequence actions:bMotion,follow,eMotion,nil];
    [self->subject_ runAction:[CCScaleTo actionWithDuration:.44f scale:1.3f]];
    [self->subject_ runAction:moveFollow];
}

-(void)revertTo:(CCNode*)center{

    
    //all very similar to followNode, but reverts to initial zoom
    [self->subject_ stopAllActions];
    
    self.target = center;
    
    id bMotion = [CCCallFunc actionWithTarget:self selector:@selector(beginMotion)];
    id follow  = [CCCallFunc actionWithTarget:self selector:@selector(followDel)];
    id eMotion = [CCCallFunc actionWithTarget:self selector:@selector(endMotion)];
    
    id moveFollow = [CCSequence actions:bMotion,follow,eMotion,nil];
    [self->subject_ runAction:[CCScaleTo actionWithDuration:.5f scale:1.f]];
    [self->subject_ runAction:moveFollow];
    
}

-(void)panBy:(CGPoint)diff{
    
    [self->subject_ stopAllActions];
    CGPoint oldPos = self->subject_.position;
    [self->subject_ setPosition:ccpAdd(oldPos,diff)];

}

-(void)panTo:(CGPoint)dest{
    
    [self->subject_ stopAllActions];
    [self->subject_ setPosition:dest];
    
}



-(void)zoomBy:(float)diff atScaleCenter:(CGPoint)scaleCenter{
    
    [self->subject_ stopAllActions];
    
    float scale = self->subject_.scale;
    
    // Set the scale.
    [self->subject_ setScale: scale*diff];
    
    //translate by zoom amount
    CGPoint currentUpdatedOrigin = ccpMult(self.zoomOrigin, self->subject_.scale);
    [self panBy:ccpSub(scaleCenter, currentUpdatedOrigin)];
}

-(void)createShakeEffect:(float)dt{
    
        //the shakeRate will determine the weight given to dt
        float shakeRate = 70;
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
    if(self.actionIntensity < .1f)
    {
        self.actionIntensity = 0;
        self->subject_.rotation = 0;
        actionCount = 0;
    }
    else
    {
        [self createShakeEffect:dt];
        
        //decrease intensity
        self.actionIntensity = self.actionIntensity*.87f;
    }
    
}


-(void)touchesBegan:(NSSet *)touches{
    
    if([touches count] == 2)
    {
        
        UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
        UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
        
        CGPoint touchLocation1 = [touch1 locationInView: [touch1 view]];   
        touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
        touchLocation1 = [self->subject_ convertToNodeSpace:touchLocation1];
        
        
        CGPoint touchLocation2 = [touch2 locationInView: [touch2 view]];   
        touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
        touchLocation2 = [self->subject_ convertToNodeSpace:touchLocation2];
        
        self.zoomOrigin =ccpMult(ccpAdd(touchLocation1,touchLocation2),.5f); 
       
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
        CGPoint prevLocation = [touch previousLocationInView: [touch view]];
        
        touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

        
        prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];

        
        CGPoint diff = ccpSub(touchLocation,prevLocation);
        [self panBy:diff];
    }
}

-(void)handleTwoFingerMotion:(NSSet *)touches{
    
    /**
     * Uses pinch to zoom and scrolling simultaneously
     */
    
    /* PANNING */
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
    
    
    /* ZOOMING */
    
    touchLocation2 = [self->subject_ convertToNodeSpace:touchLocation2];
    prevLocation2 = [self->subject_ convertToNodeSpace:prevLocation2];
    touchLocation1 = [self->subject_ convertToNodeSpace:touchLocation1];
    prevLocation1 = [self->subject_ convertToNodeSpace:prevLocation1];
    
    averageCurrentPosition = ccpMult(ccpAdd(touchLocation1,touchLocation2),.5f);
    averageLastPosition    = ccpMult(ccpAdd(prevLocation1,prevLocation2),.5f);

    
    float difScale = 
    ccpLength(ccpSub(touchLocation1,touchLocation2))/ccpLength(ccpSub(prevLocation1,prevLocation2));
    
    CGPoint diffPos = ccpMult(averageCurrentPosition,self->subject_.scale);
    [self zoomBy:difScale atScaleCenter:diffPos];

    
    
    

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

@end
