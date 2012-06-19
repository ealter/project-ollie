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

@interface AccountCreator () <Login_Delegate>

/* Used so that we can login after account creation */
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) Login *login;
@property (nonatomic, strong) NSURLConnection *connection;

- (void)broadcastAccountCreationSucceeded;
- (void)broadcastAccountCreationFailedWithError:(NSString *)error;

@end

@implementation AccountCreator

@synthesize delegate = _delegate;
@synthesize username = _username;
@synthesize password = _password;
@synthesize login = _login;
@synthesize connection = _connection;

- (void)broadcastAccountCreationSucceeded
{
    if([self.delegate respondsToSelector:@selector(accountCreationSucceeded)])
        [self.delegate accountCreationSucceeded];
}

- (void)broadcastAccountCreationFailedWithError:(NSString *)error
{
    if([self.delegate respondsToSelector:@selector(accountCreationFailedWithError:)])
        [self.delegate accountCreationFailedWithError:error];
}

- (void)createAccountWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    if([username hasWhitespace])
        [self broadcastAccountCreationFailedWithError:@"Username cannot contain whitespace"];
    else if(!username)
        [self broadcastAccountCreationFailedWithError:@"Username cannot be blank"];
    else if(!password)
        [self broadcastAccountCreationFailedWithError:@"Password cannot be blank"];
    else if(!email)
        [self broadcastAccountCreationFailedWithError:@"Email cannot be blank"];
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
        
        self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(!data_) {
        [self broadcastAccountCreationFailedWithError:nil];
        DebugLog(@"Data is nil!!!");
        return;
    }
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data_ options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error when creating account: %@", error);
        [self broadcastAccountCreationFailedWithError:@"Internal server error"];
        return;
    }
    if([result objectForKey:SERVER_ERROR_KEY]) {
        NSString *error = [result objectForKey:SERVER_ERROR_KEY];
        DebugLog(@"Error when creating account: %@", error);
        [self broadcastAccountCreationFailedWithError:error];
        return;
    }
    
    self.login = [[Login alloc]init];
    self.login.delegate = self;
    [self.login loginWithUsername:self.username password:self.password];
}

- (void)loginSucceeded
{
    [self broadcastAccountCreationSucceeded];
}

- (void)loginFailedWithError:(NSString *)error
{
    [self broadcastAccountCreationFailedWithError:[@"Account creation was successful, but login failed. The error was " stringByAppendingString:error]];
}

- (void)dealloc
{
    //[self.login release];
    //[self.connection release];
    [super dealloc];
}

@end
