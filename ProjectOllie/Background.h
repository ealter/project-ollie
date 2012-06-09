//
//  ScrollingBackground.h
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Background : CCLayer 

@property float scrollSpeed;

- (id)initWithSpeed:(int)speed images:(NSArray *)imageNames; //An nsarray is NSString's
- (void)scroll:(ccTime)dt;
+ (CCScene *)scene;

@end
