//
//  CharacterScreen.h
//  ProjectOllie
//
//  Created by Lion User on 6/21/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "SWTableView.h"
#import "Menu.h"

@class CCScrollView;

@interface CharacterScreen : Menu <SWTableViewDataSource, SWTableViewDelegate>
{
    SWTableView * tableView;
}

@property (nonatomic, retain) CCScrollView *weaponScrollView;

@end
