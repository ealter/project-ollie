//
//  DrawMenu.m
//  ProjectOllie
//
//  Created by Lion Tucker on 6/11/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "DrawMenu.h"
#import "DrawEnvironment.h"
#import "cocos2d.h"
#define HEIGHT_MULTIPLIER 0.84

@interface DrawMenu ()
@property (nonatomic, strong) CCSprite *selected;
@end

@implementation DrawMenu

@synthesize selected = _selected;
@synthesize delegate = _delegate;

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
    [self.delegate DrawMenu_setBrushRadius:largeradius];
    self.selected.position = CGPointMake(self.contentSize.width*0.357, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedMedium:(id)sender
{
    [self.delegate DrawMenu_setBrushRadius:mediumradius];
    self.selected.position = CGPointMake(self.contentSize.width*0.461, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedSmall:(id)sender
{
    [self.delegate DrawMenu_setBrushRadius:smallradius];
    self.selected.position = CGPointMake(self.contentSize.width*0.565, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedEraser:(id)sender
{
    [self.delegate DrawMenu_setBrushRadius:-mediumradius];
    self.selected.position = CGPointMake(self.contentSize.width*0.669, self.contentSize.height * HEIGHT_MULTIPLIER);
}

-(void)pressedCheck:(id)sender
{
    [self.delegate DrawMenu_doneDrawing];
}

-(void)pressedClear:(id)sender
{
    [self.delegate DrawMenu_clearDrawing];
}

-(void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

@end
