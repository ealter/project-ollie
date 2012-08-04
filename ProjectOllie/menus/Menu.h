//
//  Menu.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/22/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "CCLayer.h"

@interface Menu : CCLayer

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

/* Transitions to the specified scene. */
- (void)transitionToSceneWithFile:(NSString *)sceneName;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;

@end
