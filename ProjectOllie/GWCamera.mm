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

/*private helper functions*/
-(void)createShakeEffect:(float)dt;

@end

@implementation GWCamera

//properties for everyone to see/change
@synthesize isChanging      = _isChanging;
@synthesize target          = _target;
@synthesize actionIntensity = _actionIntensity;

-(id)initWithSubject:(CCNode *)subject worldDimensions:(CGSize)wd{
    
    if(( self = [super init] ))
    {
        self->subject_ = subject;
        self.target = self->subject_;
        self.isChanging = NO;
        self->worldDimensions = wd;
        self.actionIntensity = 0;
        self->actionCount = 0;

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
    [self->subject_ runAction:[CCScaleTo actionWithDuration:.22f scale:1.f]];
    [self->subject_ runAction:moveFollow];
    
}

-(void)panTo:(CGPoint)location{
    
    CGPoint scaledLocation = ccpMult(location, self->subject_.scale);
    id bMotion = [CCCallFunc actionWithTarget:subject_ selector:@selector(beginMotion)];
    id move    = [CCMoveTo actionWithDuration:.44f position:scaledLocation];
    id eMotion = [CCCallFunc actionWithTarget:subject_ selector:@selector(endMotion)];

    id moveFollow = [CCSequence actions:bMotion,move,eMotion,nil];
    [self->subject_ runAction:moveFollow];
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
    
    
    //decrease
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
