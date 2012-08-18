//
//  GWCamera.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/4/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ccTypes.h"
#import "CCLayer.h"

@class CCNode;
@class PanTouchLayer;

@interface GWCamera : NSObject

@property (assign, nonatomic) ccVertex3F location;      // Authoritative location of the camera in untransformed pixel space

@property (assign, nonatomic) float z0;                 // Camera angle descriptor: distance to the projection panel at which
                                                        // things are scaled to 1

@property (assign, nonatomic) float zOut;               // The farthest back the camera can go, most zoomed out it can be

@property (assign, nonatomic) bool track;               // When true, the camera automatically moves to see everything it's tracking

@property (strong, nonatomic) NSMutableArray* targets;  // The things we're currently tracking... if we are

@property (assign, nonatomic) float actionIntensity;    // The level of intensity the camera is experiencing

@property (assign, nonatomic) ccVertex2F center;        // The screen coord centerpoint on the projection plane relative to (0, 0)

@property (assign, nonatomic) float angle;              // Angle of the camera in radians

/* Inits the camera with a world and its dimensions */
-(id)initWithScreenDimensions:(CGSize)sd;

/* Starts following the given node with realistic motion */
-(void)followNode:(CCNode*)focused;

/* Moves the camera to a given location directly */
-(void)panBy:(CGPoint)diff;

/* Changes zoom by given amount */
-(void)zoomBy:(float)diff withAverageCurrentPosition:(CGPoint)currentPosition;

/* Adds intensity to the camera, lets it know how crazy what it's viewing is */
-(void)addIntensity:(float)intensity;

/* Updates camera values */
-(void)update:(float)dt;

-(PanTouchLayer*)createPanTouchLayer;

@end



/* Public helper class for panning and zooming the camera */
@interface PanTouchLayer : CCLayer

@property (strong, nonatomic) GWCamera* gwCamera;

- (id) initWithCamera:(GWCamera*)gwCamera;

@end

