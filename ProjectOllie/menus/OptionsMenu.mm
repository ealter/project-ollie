//
//  OptionsMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsMenu.h"
#import "CCBReader.h"
#import "Authentication.h"
@implementation OptionsMenu

-(id)init
{
    if (self = [super init]) {
        Authentication *myself = [Authentication mainAuth];
        
        userName = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"Current Username: %@", myself.username] fontName:@"Helvetica" fontSize:20];
        userName.position=ccp(self.contentSize.width*0.5, self.contentSize.height*4/5);
        [self addChild:userName z:1];
    }
    
    return self;
}

-(void)pressedChangeUsername:(id)sender
{
    
}

-(void)pressedBack:(id)sender
{
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
