//
//  MainMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/14/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "MainMenu.h"
#import "CCBReader.h"
#import "DrawEnvironmentScene.h"
#import "SandboxScene.h"
#import "Logout.h"
#import "Authentication.h"
#import "GWParticles.h"
#import "cocos2d.h"

#define NG_X self.contentSize.width*0.27
#define NG_Y self.contentSize.height*0.22
#define STORE_X self.contentSize.width*0.73
#define STORE_Y self.contentSize.height*0.22
#define TEAM_X self.contentSize.width*0.73
#define TEAM_Y self.contentSize.height*0.5
#define SBOX_X self.contentSize.width*0.27
#define SBOX_Y self.contentSize.height*0.5


@interface MainMenu ()

- (void)receivedNotification:(NSNotification *)notification;

@end

@implementation MainMenu
@synthesize emitter = _emitter;

-(id)init
{
    if (self=[super init]) {
        userName = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"Welcome, %@", [Authentication mainAuth].username] fontName:@"Chalkduster" fontSize:13 * [[UIScreen mainScreen]bounds].size.width/480];
        userName.anchorPoint = ccp(0.5,1);
        userName.position=ccp(self.contentSize.width*0.5, self.contentSize.height);
        [self addChild:userName z:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:(NSString *)kUsernameChangedBroadcast object:nil];
        self.emitter = Nil;
        CCLayerGradient *gradientLayer = [CCLayerGradient layerWithColor:ccc4(0, 150, 0, 255) fadingTo:ccc4(0, 200, 0, 255) alongVector:ccp(0, -1)];
        [gradientLayer setBlendFunc:(ccBlendFunc) { GL_ONE, GL_ONE_MINUS_SRC_ALPHA }];
        gradientLayer.contentSize = self.contentSize;
        gradientLayer.position  = CGPointMake(0, 0);
        [self addChild:gradientLayer z:-1];
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
    self.emitter = [GWParticleMenuLeaf node];
    self.emitter.position = CGPointMake(SBOX_X, SBOX_Y);
    [self addChild:self.emitter];
    
    CCScene* scene = [SandboxScene node];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedDraw:(id)sender
{
    CCScene* scene = [DrawEnvironmentScene node];
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

- (void)pressedStore:(id)sender
{
    [self transitionToSceneWithFile:@"TokenPurchasesScreen.ccbi"];
}

-(void)pressedLogout:(id)sender
{
    [[[Logout alloc]init] logout];
    [self transitionToSceneWithFile:@"LoginScreen.ccbi"];
}

-(void)finishButtonAndGoTo:(CCScene *)nextScene orCCBuilder:(NSString *)ccbiFile
{
    if ([nextScene isEqual:Nil]) {
        [self transitionToSceneWithFile:ccbiFile];
    }else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:nextScene withColor:ccc3(0, 0, 0)]];

    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
