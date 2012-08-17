//
//  TokenPurchasesScreen.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/14/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "TokenPurchasesScreen.h"
#import <StoreKit/StoreKit.h>
#import "cocos2d.h"
#import "InAppPurchaseIdentifiers.h"
#import "StoreTableCell.h"

@interface TokenPurchasesScreen () <ServerAPI_delegate, SKProductsRequestDelegate>

@property (nonatomic, strong) NSArray *products; //An array of SKProduct objects

- (void)getProductIdentifiers;

@end

@implementation TokenPurchasesScreen
@synthesize products = _products;

- (id)init
{
    if(self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGSize tableViewSize = CGSizeMake(winSize.width, 100);
        purchasesTable_ = [SWTableView viewWithDataSource:self size:tableViewSize];
        
        purchasesTable_.direction         = SWScrollViewDirectionVertical;
        purchasesTable_.anchorPoint       = CGPointZero;
        purchasesTable_.position          = CGPointZero;
        purchasesTable_.contentOffset     = CGPointZero;
        purchasesTable_.delegate          = self;
        purchasesTable_.verticalFillOrder = SWTableViewFillTopDown;
        
        [self addChild:purchasesTable_];
        [self getProductIdentifiers];
    }
    return self;
}

- (void)getProductIdentifiers
{
    InAppPurchaseIdentifiers *identifiers = [[InAppPurchaseIdentifiers alloc] init];
    identifiers.delegate = self;
    [identifiers getIdentifiers];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    DebugLog(@"We gots da products: %@", response.products);
    self.products = [response products];
    [purchasesTable_ reloadData];
}

- (void)serverOperation:(ServerAPI *)operation succeededWithData:(id)data
{
    //Since there are a couple different api calls in this file, we have to see which one to respond to
    if([operation isKindOfClass:[InAppPurchaseIdentifiers class]]) {
        if(![data isKindOfClass:[NSArray class]]) {
            DebugLog(@"I should have received an nsarray, but alas I did not. I received %@ which is a %@", data, [data class]);
        } else {
            NSArray *tokenNumbers = data;
            NSMutableSet *identifiers = [NSMutableSet setWithCapacity:tokenNumbers.count];
            for(id tokenNum in tokenNumbers) {
                [identifiers addObject:[tokenNum description]];
            }
            SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
            productRequest.delegate = self;
            [productRequest start];
        }
    } else {
        DebugLog(@"We got an unknown class! %@", [operation class]);
    }
}

- (void)serverOperation:(ServerAPI *)operation failedWithError:(NSString *)error
{
    DebugLog(@"The server operation failed :( with error %@", error);
    //TODO: maybe show an alert?
}

-(CGSize)cellSizeForTable:(SWTableView *)table
{
    return CGSizeMake(table.contentSize.width, 100);
}

-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
    StoreTableCell *cell = (StoreTableCell *)[table dequeueCell];
    if (!cell) {
        cell = [StoreTableCell new];
	}
    assert([cell isKindOfClass:[StoreTableCell class]]);
    cell.product = [self.products objectAtIndex:idx];
    
    return cell;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table
{
    return self.products.count;
}

-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell
{
    DebugLog(@"You touched my cell!");
    //TODO: go buy the item
}

- (void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi"];
}

@end
