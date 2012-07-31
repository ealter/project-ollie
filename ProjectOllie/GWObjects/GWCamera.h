//
//  GWCamera.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/4/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCNode;

@protocol CameraObject <NSObject>

-(float)getParallaxRatio;
-(bool)isBounded;

@end

@interface GWCamera : NSObject
{
    CCNode* subject_; //The world we are observing
}
@property (assign, nonatomic) bool isChanging;          // Tells whether or not camera is transitioning

@property (strong, nonatomic) CCNode* target;           // The target in the world we are following

@property (strong, nonatomic) NSMutableArray* children; // The other nodes that move in relation to the subject

@property (assign, nonatomic) float actionIntensity;    // The level of intensity the camera is experiencing,
                                                        // used for shaking effects currently.

@property (assign, nonatomic) float maximumScale;       // maximum scale size

@property (assign, nonatomic) float minimumScale;       // minimum scale size

@property (assign, nonatomic) float defaultScale;       // default scale size

@property (assign, nonatomic) bool bounded;             // check the bounds?

/* Inits the camera with a world and its dimensions */
-(id)initWithSubject:(CCNode *)subject screenDimensions:(CGSize)sd;

/* sets a new subject to affect */
-(void)setSubject:(CCNode*)sub;

/* Starts following the given node with realistic motion */
-(void)followNode:(CCNode*)focused;

/* Moves the camera to a given location directly */
-(void)panBy:(CGPoint)diff;

/* Pans to a given destination */
-(void)panTo:(CGPoint)dest;

/* Changes zoom by given amount */
-(void)zoomBy:(float)diff withAverageCurrentPosition:(CGPoint)currentPosition;

/* Reverts camera to default zoom settings at a given location */
-(void)revert;

/* Adds intensity to the camera, lets it know how crazy what it's viewing is */
-(void)addIntensity:(float)intensity;

/* Updates camera values */
-(void)update:(float)dt;

/* Handles touches beginning */
-(void)touchesBegan:(NSSet *)touches;

/* Handles touches moving */
-(void)touchesMoved:(NSSet *)touches;

/* Handles touches beginning */
-(void)touchesEnded:(NSSet *)touches;

@end