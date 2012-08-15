//
//  TokenPurchasesScreen.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/14/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "TokenPurchasesScreen.h"
#import "cocos2d.h"

@interface TokenPurchasesScreen ()

@end

@implementation TokenPurchasesScreen

- (id)init
{
    if(self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGSize tableViewSize = CGSizeMake(winSize.width, 100);
        purchasesTable_ = [SWTableView viewWithDataSource:self size:tableViewSize];
        
        purchasesTable_.direction         = SWScrollViewDirectionHorizontal;
        purchasesTable_.anchorPoint       = CGPointZero;
        purchasesTable_.position          = CGPointZero;
        purchasesTable_.contentOffset     = CGPointZero;
        purchasesTable_.delegate          = self;
        purchasesTable_.verticalFillOrder = SWTableViewFillTopDown;
        
        [self addChild:purchasesTable_];
    }
    return self;
}

/**
 * cell height for a given table.
 *
 * @param table table to hold the instances of Class
 * @return cell size
 */
-(CGSize)cellSizeForTable:(SWTableView *)table
{
    
}
/**
 * a cell instance at a given index
 *
 * @param idx index to search for a cell
 * @return cell found at idx
 */
-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
    
}
/**
 * Returns number of cells in a given table view.
 * 
 * @return number of cells
 */
-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table
{
    
}

-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell
{
    
}

- (void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

@end
