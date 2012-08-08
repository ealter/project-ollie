//
//  GWGestures.h
//  ProjectOllie
//
//  Created by Lion User on 7/18/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLayer.h"
#import "SWTableView.h"


@class GWCharacter;
@class CCParticleSystem;

@protocol GestureChild <NSObject>
-(void)handleSwipeRightWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handleSwipeLeftWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handleSwipeUpWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handleSwipeDownWithAngle:(float) angle andLength:(float) length andVelocity:(float) velocity;

-(void)handlePanWithStart:(CGPoint) startPoint andCurrent:(CGPoint) currPoint andTime:(float) time;

-(void)handlePanFinishedWithStart:(CGPoint) startPoint andEnd:(CGPoint) endPoint andTime:(float) time;

-(void)handleTap:(CGPoint) tapPoint;

@end

@interface GWGestures : CCLayer{
}

@property (strong, nonatomic) NSMutableArray* children; // Nodes that need gesture activation

@property (strong, nonatomic) CCNode<GestureChild>* touchTarget; //The child that is touched

@end
