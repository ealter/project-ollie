//
//  ScrollingBackground.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Background.h"


@implementation Background
@synthesize scrollspeed = _scrollspeed;
@synthesize parallax    = _parallax;


-(id)initwithSpeed:(float) speed
{
    if (self = [super init]) {
        self.scrollspeed = speed;
        self.parallax    = [CCParallaxNode node];
        CCSprite* bglayer1 = [CCSprite spriteWithFile:@"background.jpg"];
        bglayer1.scale = 3.f;
        
        
        
        [self.parallax addChild:bglayer1 z:-1 parallaxRatio:ccp(.4f,.5f) positionOffset:CGPointZero];
        //create both sprite to handle background
        /*
        background = [CCSprite spriteWithFile:imagename];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        background2 = [CCSprite spriteWithFile:imagename];
        background2.anchorPoint = ccp(0,0);
        background2.position = ccp([background boundingBox].size.width-1, 0);
        */
        
        //add them to main layer
        //[self addChild:background];
        //[self addChild:background2];
        //add schedule to move backgrounds
        // [self schedule:@selector(scroll:) interval:0.005];
    }
    return self;
}


- (void) scroll:(ccTime)dt{
    /*
    background.position = ccp( background.position.x - scrollspeed, background.position.y);
    background2.position = ccp( background2.position.x - scrollspeed, background2.position.y);
    
	//reset position when they are off from view.
    if (background.position.x < -[background boundingBox].size.width ) {
        background.position = ccp(background2.position.x+[background2 boundingBox].size.width, background.position.y);
    }
    
	if (background2.position.x < -[background2 boundingBox].size.width ) {
        background2.position = ccp(background.position.x+[background boundingBox].size.width, background2.position.y);
    }*/
    
}

@end
