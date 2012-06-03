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
@synthesize gpc_polys, newpoly;

-(id) init
{
	if(self=[super init]) {
        
	}
	return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    newpoly = [[polywrapper alloc] init];
    
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [gpc_polys addObject:newpoly];
}

@end
