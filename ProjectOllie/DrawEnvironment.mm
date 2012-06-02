//
//  DrawEnvironment.m
//  ProjectOllie
//
//  Created by Lion User on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DrawEnvironment.h"
#import "AppDelegate.h"
#import "PhysicsSprite.h"
@implementation DrawEnvironment


-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		CGSize s = [CCDirector sharedDirector].winSize;
		
		[self scheduleUpdate];
	}
	return self;
}



- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
