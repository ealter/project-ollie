//
//  DrawMenu.m
//  ProjectOllie
//
//  Created by Lion User on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DrawMenu.h"
#import "DrawEnvironment.h"
#import "SandboxScene.h"
#import "Terrain.h"
#import "CCBReader.h"

#define HEIGHT_MULTIPLIER 0.84

@interface DrawMenu ()
@property (nonatomic, retain) CCSprite *selected;
@end

@implementation DrawMenu

@synthesize selected = _selected;

-(id)init
{
    if (self=[super init]) {
        self.selected = [CCSprite spriteWithFile:@"selectedoption.png" rect:CGRectMake(0, 0, 35, 3)];
        [self addChild:self.selected];
        self.selected.position = CGPointMake(self.contentSize.width*0.565, self.contentSize.height * HEIGHT_MULTIPLIER);
    }
    
    return self;
}

-(void)pressedLarge:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = largeradius;
    self.selected.position = CGPointMake(self.contentSize.width*0.357, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedMedium:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = mediumradius;
    self.selected.position = CGPointMake(self.contentSize.width*0.461, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedSmall:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = smallradius;
    self.selected.position = CGPointMake(self.contentSize.width*0.565, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedEraser:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    parent_node.brushradius = -mediumradius;
    self.selected.position = CGPointMake(self.contentSize.width*0.669, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedCheck:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    SandboxScene* scene = [SandboxScene node];

    [parent_node removeChild:parent_node.terrain cleanup:YES];
    [scene.actionLayer addChild:parent_node.terrain];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

-(void)pressedClear:(id)sender
{
    DrawEnvironment *parent_node = (DrawEnvironment *)[self parent];
    [parent_node.terrain clear];
}

-(void)pressedBack:(id)sender
{
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

@end
