//
//  ScrollingBackground.h
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ScrollingBackground : CCLayer 

@property (nonatomic, retain) CCSprite *background;
@property (nonatomic, strong) CCSprite *background2;

- (void) scroll:(ccTime)dt;
+(CCScene *) scene;

@end
