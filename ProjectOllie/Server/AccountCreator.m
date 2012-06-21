//
//  AccountCreator.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "AccountCreator.h"
#import "Authentication.h"
#import "NSDictionary+URLEncoding.h"
#import "NSString+whitespace_check.h"
#import "Login.h"

@interface AccountCreator () <ServerAPI_delegate>

/* Used so that we can login after account creation */
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) Login *login;

@end

@implementation AccountCreator

@synthesize username = _username;
@synthesize password = _password;
@synthesize login = _login;

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
        NSURL *url = [[[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"] URLByAppendingPathComponent:@"newAccount"];
        NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:username, password, email, nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", @"email", nil]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        NSString *postData = [requestData urlEncodedString];
        [requestData release];
        request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
        
        [[[NSURLConnection alloc]initWithRequest:request delegate:self] release];
    }
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    self.login = [[Login alloc]init];
    self.login.delegate = self;
    [self.login loginWithUsername:self.username password:self.password];
}

- (void)serverOperationSucceeded
{
    [self broadcastServerOperationSucceeded];
}

- (void)serverOperationFailedWithError:(NSString *)error
{
    [self broadcastServerOperationFailedWithError:[@"Account creation was successful, but login failed. The error was " stringByAppendingString:error]];
}

@end
