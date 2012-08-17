//
//  StoreTableCell.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "StoreTableCell.h"
#import <StoreKit/StoreKit.h>
#import "cocos2d.h"

@interface StoreTableCell () {
    CCLabelTTF *priceLabel_;
    CCLabelTTF *titleLabel_;
    CCLabelTTF *descriptionLabel_;
}

- (NSString *)formattedPrice;
- (void)refreshView;

@end

@implementation StoreTableCell
@synthesize product = _product;

- (id)init
{
    if(self = [super init]) {
        CCSprite *sprite = [CCSprite spriteWithFile:@"Icon-72.png"]; //TODO: make this a bananananana
		sprite.anchorPoint = CGPointZero;
		[self addChild:sprite];
        
		priceLabel_ = [CCLabelTTF labelWithString:self.formattedPrice fontName:@"Helvetica" fontSize:20.0];
        priceLabel_.string = @"6969";
		priceLabel_.position = ccp(20, 20);
		[self addChild:priceLabel_];
    }
    return self;
}

- (NSString *)formattedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.product.priceLocale];
    return [numberFormatter stringFromNumber:self.product.price];
}

- (void)setProduct:(SKProduct *)product
{
    _product = product;
    [self refreshView];
}

- (void)refreshView
{
    priceLabel_.string = [self formattedPrice];
}

@end
