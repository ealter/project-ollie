//
//  GWGestures.m
//  ProjectOllie
//
//  Created by Lion User on 7/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWGestures.h"
#import "cocos2d.h"

@interface GWGestures ()
{
    //location of first touch
    CGPoint touchDown;
    
    //location of the moving touch
    CGPoint touchMove;
    
    //location of the last touch
    CGPoint touchUp;
    
    //time of first touch
    double touchDownTime;
    
    //current time of the touch
    double touchTime;
    
    //boolean for pan checking
    BOOL isPanning;
}

@end

@implementation GWGestures

-(id)init
{
    if (self = [super init]) {
        self.isTouchEnabled = YES;
    }
    
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    //Get the first touch's location and time
    UITouch *touch = [touches anyObject];
    touchDown = [touch locationInView: touch.view];
    touchDownTime = [touch timestamp];
    isPanning = NO;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    UITouch *touch = [touches anyObject];
    touchMove = [touch locationInView:touch.view];
    touchTime = [touch timestamp] - touchDownTime;
    
    if (isPanning) {
        //Handle a pan
    }else {
        if (ccpDistance(touchDown, touchMove) > 10) {
            //This is a pan, or a swipe
            if (touchTime >0.4) {
                //This is a pan
                isPanning = YES;
            }
        }
    }
     
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchUp = [touch locationInView:touch.view];
    touchTime = [touch timestamp] - touchDownTime;    
    
    if (isPanning) {
        //That was a Pan
    }else if (touchTime < 0.4 && ccpDistance(touchDown, touchUp) > 15) {
        //This means a swipe!

        //Calculate swipe direction: left, right, up down
        CGPoint swipeVec = ccpSub(touchUp, touchDown);
        if (swipeVec.x > 10 && abs(swipeVec.x) > abs(swipeVec.y)) {
            //Swipe to the right
        }else if (swipeVec.x < -10 && abs(swipeVec.x) > abs(swipeVec.y)) {
            //Swipe to the left
        }else if (swipeVec.y < -10 && abs(swipeVec.y) > abs(swipeVec.x)) {
            //Swipe upwards
        }else if (swipeVec.y > 10 && abs(swipeVec.y) > abs(swipeVec.x)) {
            //Swipe downwards
        }
        
    }else if (touchTime < 0.3 && ccpDistance(touchDown, touchUp) < 5) {
        //This means a tap!
    }
}

@end
