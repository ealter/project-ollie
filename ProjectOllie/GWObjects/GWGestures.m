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
@synthesize children        = _children;

-(id)init
{
    if (self = [super init]) {
        self.isTouchEnabled = YES;
        self.children = [NSMutableArray array];
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
        for (CCNode<GestureChild> *child in self.children) {
            [child handlePanWithStart:touchDown andCurrent:touchMove andTime:touchTime];
        }
    }else {
        if (ccpDistance(touchDown, touchMove) > 10) {
            //This is a pan, or a swipe
            if (touchTime >0.3) {
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
        for (CCNode<GestureChild> *child in self.children) {
            [child handlePanFinishedWithStart:touchDown andEnd:touchMove andTime:touchTime];
        }
    }else if (touchTime < 0.4 && ccpDistance(touchDown, touchUp) > 15) {
        //This means a swipe!
        
        //Calculate swipe direction: left, right, up down
        CGPoint swipeVec = ccpSub(touchUp, touchDown);
        float angle = atan2f(touchUp.x-touchDown.x, touchUp.y-touchDown.y);
        float len   = ccpDistance(touchDown, touchUp);
        float vel   = len / touchTime;
        if (swipeVec.x > 10 && abs(swipeVec.x) > abs(swipeVec.y)) {
            //Swipe to the right
            for (CCNode<GestureChild> *child in self.children) {
                [child handleSwipeRightWithAngle:angle andLength:len andVelocity:vel];
            }
        }else if (swipeVec.x < -10 && abs(swipeVec.x) > abs(swipeVec.y)) {
            //Swipe to the left
            for (CCNode<GestureChild> *child in self.children) {
                [child handleSwipeLeftWithAngle:angle andLength:len andVelocity:vel];
            }
        }else if (swipeVec.y < -10 && abs(swipeVec.y) > abs(swipeVec.x)) {
            //Swipe upwards
            for (CCNode<GestureChild> *child in self.children) {
                [child handleSwipeUpWithAngle:angle andLength:len andVelocity:vel];
            }
        }else if (swipeVec.y > 10 && abs(swipeVec.y) > abs(swipeVec.x)) {
            //Swipe downwards
            for (CCNode<GestureChild> *child in self.children) {
                [child handleSwipeDownWithAngle:angle andLength:len andVelocity:vel];
            }
        }
        
    }else if (touchTime < 0.3 && ccpDistance(touchDown, touchUp) < 5) {
        //This means a tap!
        for (CCNode<GestureChild> *child in self.children) {
            [child handleTap:touchUp];
        }
    }
}

@end
