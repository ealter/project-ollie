//
//  StoreTableCell.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "SWTableViewCell.h"

@class SKProduct;

@interface StoreTableCell : SWTableViewCell

@property (nonatomic, strong) SKProduct *product;

- (id)initWithContentSize:(CGSize)contentSize;

@end
