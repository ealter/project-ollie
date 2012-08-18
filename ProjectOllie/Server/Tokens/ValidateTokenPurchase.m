//
//  ValidateTokenPurchase.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/17/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ValidateTokenPurchase.h"
#import "NSData+Base64.h"

@implementation ValidateTokenPurchase

- (void)validateTokenPurchase:(NSData *)receiptData
{
    NSDictionary *requestData = [NSDictionary dictionaryWithObject:[receiptData base64EncodedString] forKey:@"receipt-data"];
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"validateTokenPurchase"] includeAuthentication:YES];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    [self broadcastServerOperationSucceededWithData:[result objectForKey:@"tokens"]];
}

@end
