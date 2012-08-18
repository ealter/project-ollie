//
//  ResetPassword.m
//  ProjectOllie
//
//  Created by Eliot Alter on 8/2/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ResetPassword.h"

@implementation ResetPassword

- (void)resetPasswordForEmail:(NSString *)email
{
    if(!email) {
        [self broadcastServerOperationFailedWithError:@"Missing email address"];
        return;
    }
    NSDictionary *requestData = [NSDictionary dictionaryWithObject:email forKey:@"email"];
    [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"sendRecoveryEmail"] includeAuthentication:NO];
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    [[[UIAlertView alloc] initWithTitle:@"Email sent" message:@"If the provided email is associated with an account, an email will be sent with instructions on how to reset the password." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

@end
