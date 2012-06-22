//
//  MainMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "CCBReader.h"
#import "DrawEnvironment.h"
#import "SandboxScene.h"
#import "Logout.h"
#import "Authentication.h"

@interface MainMenu ()

- (void)receivedNotification:(NSNotification *)notification;

@end

@implementation MainMenu

-(id)init
{
    if (self=[super init]) {
        userName = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"Welcome, %@", [Authentication mainAuth].username] fontName:@"Chalkduster" fontSize:13];
        userName.anchorPoint = ccp(0.5,1);
        userName.position=ccp(self.contentSize.width*0.5, self.contentSize.height);
        [self addChild:userName z:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:USERNAME_CHANGED_BROADCAST object:nil];
    }
    
    return self;
}

- (void)receivedNotification:(NSNotification *)notification
{
    if([notification.name isEqualToString:USERNAME_CHANGED_BROADCAST]) {
        [userName setString:[Authentication mainAuth].username];
    }
}

-(void)pressedMakeSquares: (id)sender
{
    SandboxScene *scene = [SandboxScene node];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedDraw:(id)sender
{
    CCScene* scene = [DrawEnvironment scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedOptions:(id)sender
{
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"OptionsMenu.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedNewGame:(id)sender
{
    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
    [colorLayer setOpacity:190];
    [self addChild:colorLayer z:1];
    
    CCNode* newnode = [CCBReader nodeGraphFromFile:@"NewGameOverlay.ccbi"];
    [self addChild:newnode];
    [self reorderChild:newnode z:2];
}

-(void)pressedLogout:(id)sender
{
    Logout *logout = [[Logout alloc]init];
    [logout logout];
    [logout release];
    
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"LoginScreen.ccbi"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
