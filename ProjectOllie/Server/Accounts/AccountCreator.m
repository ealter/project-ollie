//
//  AccountCreator.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "AccountCreator.h"
#import "Authentication.h"
#import "NSString+whitespace_check.h"
#import "Login.h"

@interface AccountCreator () <ServerAPI_delegate>

/* Used so that we can login after account creation */
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end

@implementation AccountCreator

@synthesize username = _username;
@synthesize password = _password;

- (void)createAccountWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    if([username hasWhitespace])
        [self broadcastServerOperationFailedWithError:@"Username cannot contain whitespace"];
    else if(!username)
        [self broadcastServerOperationFailedWithError:@"Username cannot be blank"];
    else if(!password)
        [self broadcastServerOperationFailedWithError:@"Password cannot be blank"];
    else if(!email)
        [self broadcastServerOperationFailedWithError:@"Email cannot be blank"];
    else {
        self.username = username;
        self.password = password;
        NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:username, password, email, nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", @"email", nil]];
        [self makeServerRequestWithData:requestData url:[[self class] urlForPageName:@"newAccount"]];
    }
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    Login *login = [[Login alloc]init];
    login.delegate = self;
    [login loginWithUsername:self.username password:self.password];
}

- (void)serverOperationSucceededWithData:(id)data
{
    [self broadcastServerOperationSucceededWithData:nil];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    [self broadcastServerOperationFailedWithError:[@"Account creation was successful, but login failed. The error was " stringByAppendingString:error]];
}

@end
