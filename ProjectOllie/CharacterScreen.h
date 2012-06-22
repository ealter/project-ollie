//
//  CharacterScreen.h
//  ProjectOllie
//
//  Created by Lion User on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollView.h"
#import "SWTableView.h"

@interface CharacterScreen : CCLayer <SWTableViewDataSource, SWTableViewDelegate>
{
    SWTableView * tableView;
}

@property (nonatomic, retain) CCScrollView *weaponScrollView;

@end
