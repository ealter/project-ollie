//
//  Menu.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/22/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "CCLayer.h"

@interface Menu : CCLayer

/* Transitions to the specified scene. If uiviews is not nil, it calls removeFromSuperview and release on each element. */
- (void)transitionToSceneWithFile:(NSString *)sceneName removeUIViews:(NSArray *)uiviews;

@end
