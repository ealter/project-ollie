//
//  ScrollingBackground.h
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


//TODO:
//  Give Parallax (make independent of parallax node)


#import <Foundation/Foundation.h>
#import "CCLayer.h"

@interface Background : CCLayer 

@property (assign, nonatomic) float scrollSpeed; /* In pixels/second. Positive means left to right, negative means right to left. */
@property (nonatomic, strong) NSArray *imageNames; //An array of NSStrings

- (id)initWithSpeed:(int)speed images:(NSArray *)imageNames;
- (void)scroll:(ccTime)dt;

@end