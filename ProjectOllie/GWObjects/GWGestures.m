//
//  GWGestures.m
//  ProjectOllie
//
//  Created by Lion User on 7/18/12.
//  Copyright 2012 hi ku llc. All rights reserved.
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

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{    
    //Get the first touch's location and time
    touchDown = [touch locationInView: touch.view];
    touchDownTime = [touch timestamp];
    touchDown = [[CCDirector sharedDirector] convertToGL:touchDown];
    touchDown = [self convertToNodeSpace:touchDown];
    isPanning = NO;
    
    for (CCNode<GestureChild> *child in self.children) {
        if (ccpDistance(touchDown, child.position) < child.contentSize.width) {
            return YES;
        }
    }
    return NO;
}


-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{    
    touchMove = [touch locationInView:touch.view];
    touchMove = [[CCDirector sharedDirector] convertToGL:touchMove];
    touchMove = [self convertToNodeSpace:touchMove];
    touchTime = [touch timestamp] - touchDownTime;
    
    if (isPanning) {
        //Handle a pan
        for (CCNode<GestureChild> *child in self.children) {
            
            [child handlePanWithStart:touchDown andCurrent:touchMove andTime:touchTime];
        }
    }else {
        if (ccpDistance(touchDown, touchMove) > 5) {
            //This is a pan, or a swipe
            if (touchTime >0.2) {
                //This is a pan
                isPanning = YES;
            }
        }
    }
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    touchUp = [touch locationInView:touch.view];
    touchUp = [[CCDirector sharedDirector] convertToGL:touchUp];
    touchUp = [self convertToNodeSpace:touchUp];
    touchTime = [touch timestamp] - touchDownTime;    
    
    if (isPanning) {
        //That was a Pan
        for (CCNode<GestureChild> *child in self.children) {
            [child handlePanFinishedWithStart:touchDown andEnd:touchMove andTime:touchTime];
        }
    }else if (touchTime < 0.2 && ccpDistance(touchDown, touchUp) > 15) {
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
        
    }else if (touchTime < 0.2 && ccpDistance(touchDown, touchUp) <= 15) {
        //This means a tap!
        for (CCNode<GestureChild> *child in self.children) {
            [child handleTap:touchUp];
        }
    }
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];

}

@end
