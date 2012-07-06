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
#import "cocos2d.h"

@interface MainMenu ()

- (void)receivedNotification:(NSNotification *)notification;

@end

@implementation MainMenu

-(id)init
{
    if (self=[super init]) {
        userName = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"Welcome, %@", [Authentication mainAuth].username] fontName:@"Chalkduster" fontSize:13 * [[UIScreen mainScreen]bounds].size.width/480];
        userName.anchorPoint = ccp(0.5,1);
        userName.position=ccp(self.contentSize.width*0.5, self.contentSize.height);
        [self addChild:userName z:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:(NSString *)kUsernameChangedBroadcast object:nil];
    }
    
    return self;
}

- (void)receivedNotification:(NSNotification *)notification
{
    if([notification.name isEqualToString:(NSString *)kUsernameChangedBroadcast]) {
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
    [self transitionToSceneWithFile:@"OptionsMenu.ccbi"];
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

-(void)pressedCharacters:(id)sender
{
    [self transitionToSceneWithFile:@"CharacterScreen.ccbi"];
}

-(void)pressedLogout:(id)sender
{
    [[[Logout alloc]init] logout];
    [self transitionToSceneWithFile:@"LoginScreen.ccbi"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
