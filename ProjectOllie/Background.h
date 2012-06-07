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

@property (nonatomic, retain) CCSprite *background;
@property (nonatomic, strong) CCSprite *background2;
@property int scrollspeed;

-(id)initwithSpeed:(int) speed andImage: (NSString *) imagename;
- (void) scroll:(ccTime)dt;
+(CCScene *) scene;

@end
