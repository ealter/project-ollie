//
//  GWCamera.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GWCamera.h"
#import "CCAction.h"
#import "CCActionInterval.h"
#import "CGPointExtension.h"
#import "CCActionInstant.h"
@interface GWCamera()

/*private functions for callfunc delegate*/
-(void)beginMotion;
-(void)endMotion;
-(void)followDel;

@end

@implementation GWCamera

//properties for everyone to see/change
@synthesize isChanging =_isChanging;
@synthesize target     =_target;

-(id)initWithSubject:(CCNode *)subject{
    
    if(( self = [super init] ))
    {
        self->subject_ = subject;
        self.target = self->subject_;
        self.isChanging = NO;
    }
    return self;
    
}

-(void)followNode:(CCNode *)focused{
    
    self.target = focused;
    
    id bMotion = [CCCallFunc actionWithTarget:self selector:@selector(beginMotion)];
    id follow  = [CCCallFunc actionWithTarget:self selector:@selector(followDel)];
    id eMotion = [CCCallFunc actionWithTarget:self selector:@selector(endMotion)];

    id moveFollow = [CCSequence actions:bMotion,follow,eMotion,nil];
    [self->subject_ runAction:[CCScaleTo actionWithDuration:.44f scale:2.f]];
    //[self->subject_ runAction:[CCFollow actionWithTarget:self.target]];
    [self->subject_ runAction:moveFollow];
}

-(void)panTo:(CGPoint)location{
    id bMotion = [CCCallFunc actionWithTarget:subject_ selector:@selector(beginMotion)];
    id move    = [CCMoveTo actionWithDuration:.44f position:location];
    id eMotion = [CCCallFunc actionWithTarget:subject_ selector:@selector(endMotion)];

    id moveFollow = [CCSequence actions:bMotion,move,eMotion,nil];
    [self->subject_ runAction:[CCScaleTo actionWithDuration:.44f scale:2.f]];
    [self->subject_ runAction:moveFollow];
}

-(void)revertTo:(CCNode*)center withWidth:(float)width Height:(float)height{

    self.target = center;
    CGPoint moveTarget = ccp(center.position.x - width/2, center.position.y - height/2);
    id bMotion = [CCCallFunc actionWithTarget:self selector:@selector(beginMotion)];
    id move    = [CCMoveTo actionWithDuration:.44f position:moveTarget];
    id follow  = [CCCallFunc actionWithTarget:self selector:@selector(followDel)];
    id eMotion = [CCCallFunc actionWithTarget:self selector:@selector(endMotion)];
    
    id moveFollow = [CCSequence actions:bMotion,move,follow,eMotion,nil];
    [self->subject_ runAction:[CCScaleTo actionWithDuration:.44f scale:1.f]];
    [self->subject_ runAction:moveFollow];
    
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
