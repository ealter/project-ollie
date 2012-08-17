//
//  TokenPurchasesScreen.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/14/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Menu.h"
#import "SWTableView.h"

@interface TokenPurchasesScreen : Menu <SWTableViewDataSource, SWTableViewDelegate> {
    SWTableView *purchasesTable_;
}

@end
