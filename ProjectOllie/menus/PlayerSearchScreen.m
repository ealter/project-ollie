//
//  PlayerSearchScreen.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/3/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "PlayerSearchScreen.h"

@implementation PlayerSearchScreen

- (id)init
{
    if(self = [super init]) {
        CGRect frame = CGRectMake(self.contentSize.height*0.2, self.contentSize.width/2, 150, 30);
        searchField_ = [self addTextFieldWithFrame:frame];
        searchField_.placeholder = @"Username";
        searchField_.delegate    = self;
    }
    return self;
}

- (void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"]; //TODO: also put up the game overlay?
}

- (void)pressedSearch:(id)sender
{
    DebugLog(@"Time to search");
}

@end
