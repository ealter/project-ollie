//
//  PlayerSearchScreen.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/3/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "PlayerSearchScreen.h"
#import "PlayerSearch.h"

@interface PlayerSearchScreen () <ServerAPI_delegate>\
@end

@implementation PlayerSearchScreen

- (id)init
{
    if(self = [super init]) {
        float height = 30;
        CGRect frame = CGRectMake(self.contentSize.height*0.8 + height/2, self.contentSize.width/2, 150, height);
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
    PlayerSearch *search = [[PlayerSearch alloc] init];
    search.delegate = self;
    [search searchForPlayerWithUsername:searchField_.text];
}

- (void)serverOperationSucceededWithData:(NSArray *)data
{
    if(![data isKindOfClass:[NSArray class]]) {
        DebugLog(@"The data I received is not an NSArray!");
        [self serverOperationFailedWithError:nil];
        return;
    }
    //TODO: show the usernames in some sort of table
    NSString *message = data.count > 0 ? @"The player exists" : @"The player was not found";
    [[[UIAlertView alloc]initWithTitle:@"Search Results" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    if(!error) error = @"unknown error";
    [[[UIAlertView alloc]initWithTitle:@"Error when searching for player" message:error delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

- (NSArray *)textFields
{
    return [NSArray arrayWithObject:searchField_];
}

@end
