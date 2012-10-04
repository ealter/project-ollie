//
//  MyStoreObserver.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/17/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "MyStoreObserver.h"
#import "ValidateTokenPurchase.h"

@interface MyStoreObserver ()

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;

@end

@implementation MyStoreObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)completeTransaction: (SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    DebugLog(@"Da transaction failed :(");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        DebugLog(@"The error is %@", transaction.error);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    ValidateTokenPurchase *validator = [[ValidateTokenPurchase alloc] init];
    //TODO: Maybe set a delegate?
    [validator validateTokenPurchase:transaction.transactionReceipt];
}

- (void)provideContent:(NSString *)productIdentifier
{
    //TODO: notify the store that the number of tokens has changed
}

@end
