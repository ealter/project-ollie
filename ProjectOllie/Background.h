//
//  ScrollingBackground.h
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Background : CCNode 

@property (assign, nonatomic) float scrollSpeed;

-(id)initwithSpeed:(float) speed;
- (void) scroll:(ccTime)dt;


@end