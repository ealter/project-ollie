//
//  GWCamera.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/4/12.
//  Copyright (c) 2012 hi ku inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNode.h"


@interface GWCamera : NSObject
{
    CCNode* subject_; //The world we are observing


}

@property (assign, nonatomic) bool isChanging;          // Tells whether or not camera is transitioning

@property (strong, nonatomic) CCNode* target;           // The target in the world we are following

@property (assign, nonatomic) float actionIntensity;    // The level of intensity the camera is experiencing,
                                                        // used for shaking effects currently.

/* Inits the camera with a world and its dimensions */
-(id)initWithSubject:(id)subject worldDimensions:(CGSize)wd;

/* Starts following the given node with realistic motion */
-(void)followNode:(CCNode*)focused;

/* Moves the camera to a given location directly */
-(void)panTo:(CGPoint)location;

/* Reverts camera to default zoom settings at a given location */
-(void)revertTo:(CCNode*)center;

/* Adds intensity to the camera, lets it know how crazy what it's viewing is */
-(void)addIntensity:(float)intensity;

/* Updates camera values */
-(void)update:(float)dt;

@end
