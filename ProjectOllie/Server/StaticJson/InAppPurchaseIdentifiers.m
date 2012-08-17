//
//  InAppPurchaseIdentifiers.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/13/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "InAppPurchaseIdentifiers.h"

@implementation InAppPurchaseIdentifiers

- (void)getIdentifiers
{
    [self makeGetRequestWithUrl:[[self class] urlForPageName:@"purchases.json"]];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    [self broadcastServerOperationSucceededWithData:[result objectForKey:@"tokens"]];
}

@end
