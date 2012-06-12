//
//  ScrollingBackground.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Background.h"

@implementation Background
@synthesize background, background2, scrollspeed;

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    Background *layer = [Background node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

-(id)initwithSpeed:(int) speed andImage: (NSString *) imagename
{
    if (self = [super init]) {
        scrollspeed = speed;
        
        
        //create both sprite to handle background
        background = [CCSprite spriteWithFile:imagename];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        background2 = [CCSprite spriteWithFile:imagename];
        background2.anchorPoint = ccp(0,0);
        background2.position = ccp([background boundingBox].size.width-1, 0);
        
        //add them to main layer
        [self addChild:background];
        [self addChild:background2];
        //add schedule to move backgrounds
        [self schedule:@selector(scroll:) interval:0.005];
    }
    return self;
}

- (void) scroll:(ccTime)dt{
    background.position = ccp( background.position.x - scrollspeed, background.position.y);
    background2.position = ccp( background2.position.x - scrollspeed, background2.position.y);
    
	//reset position when they are off from view.
    if (background.position.x < -[background boundingBox].size.width ) {
        background.position = ccp(background2.position.x+[background2 boundingBox].size.width, background.position.y);
    }
    
	if (background2.position.x < -[background2 boundingBox].size.width ) {
        background2.position = ccp(background.position.x+[background boundingBox].size.width, background2.position.y);
    }
    
}

@end
