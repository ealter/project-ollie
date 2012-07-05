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
/* If uiviews is not nil, it calls removeFromSuperview and release on each element. */
- (void)removeUIViews:(NSArray *)uiviews;
/* Adds a text field setting a bunch of common parameters */
- (UITextField *)addTextFieldWithFrame:(CGRect)frame;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;

@end
