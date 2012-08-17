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
    return [self initWithContentSize:self.contentSize];
}

- (id)initWithContentSize:(CGSize)contentSize
{
    if(self = [super init]) {
        self.contentSize = contentSize;
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"banana.png"];
		sprite.anchorPoint = CGPointZero;
        sprite.position = CGPointZero;
		[self addChild:sprite];
        
		priceLabel_ = [CCLabelTTF labelWithString:self.formattedPrice fontName:@"Helvetica" fontSize:20.0];
		priceLabel_.position = ccp(self.contentSize.width, self.contentSize.height/2);
        priceLabel_.anchorPoint = ccp(1,1);
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
    priceLabel_.string       = [self formattedPrice];
    titleLabel_.string       = self.product.localizedTitle;
    descriptionLabel_.string = self.product.localizedDescription;
}

@end
