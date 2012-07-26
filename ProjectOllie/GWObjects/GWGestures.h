//
//  GWGestures.h
//  ProjectOllie
//
//  Created by Lion User on 7/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLayer.h"

@protocol GestureChild <NSObject>
@optional
-(void)handleSwipeRightWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handleSwipeLeftWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handleSwipeUpWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handleSwipeDownWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time;

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint) endPoint andTime:(float) time;

-(void)handleTap:(CGPoint) tapPoint;

@end

@interface GWGestures : CCLayer {
    
}

@property (strong, nonatomic) NSMutableArray* children; // Nodes that need gesture activation


@end
