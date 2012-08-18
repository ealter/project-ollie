//
//  TokenPurchasesScreen.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/14/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Menu.h"
#import "SWTableView.h"

@class CCLabelTTF;

@interface TokenPurchasesScreen : Menu <SWTableViewDataSource, SWTableViewDelegate> {
    SWTableView *purchasesTable_;
    CCLabelTTF *tokensLabel_;
}

@end
