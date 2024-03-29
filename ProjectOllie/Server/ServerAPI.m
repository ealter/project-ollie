//
//  ServerAPI.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAPI.h"
#import "Authentication.h"
#import "NSDictionary+URLEncoding.h"
#import "NSString+SBJSON.h"

@implementation ServerAPI

@synthesize delegate = _delegate;

- (id)init
{
    if(self = [super init]) {
        data_ = [[NSMutableData alloc]initWithCapacity:128];
    }
    return self;
}

- (Authentication *)auth
{
    return [Authentication mainAuth];
}

- (void)broadcastServerOperationSucceededWithData:(id)data
{
    if([self.delegate respondsToSelector:@selector(serverOperation:succeededWithData:)])
        [self.delegate serverOperation:self succeededWithData:data];
}

- (void)broadcastServerOperationFailedWithError:(NSString *)error
{
    if([self.delegate respondsToSelector:@selector(serverOperation:failedWithError:)])
        [self.delegate serverOperation:self failedWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [data_ appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                 message:[error localizedDescription]
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                       otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(!data_) {
        DebugLog(@"The connection didn't receive any data");
        [self broadcastServerOperationFailedWithError:nil];
        return;
    }
    NSError *error = nil;
    NSDictionary *result = [[[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding] JSONValue];
    if(error) {
        DebugLog(@"Error when communicating with server (%@): %@", [self class], error);
        [self broadcastServerOperationFailedWithError:@"Internal server error"];
    } else if([result objectForKey:SERVER_ERROR_KEY]) {
        NSString *error = [result objectForKey:SERVER_ERROR_KEY];
        DebugLog(@"Error when communicating with server (%@): %@", [self class], error);
        [self broadcastServerOperationFailedWithError:error];
    } else {
        [self serverReturnedResult:result];
    }
}

- (void)serverReturnedResult:(NSDictionary *)result
{
    if([self isMemberOfClass:[ServerAPI class]])
        [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)makeServerRequestWithData:(NSDictionary *)requestData url:(NSURL *)url includeAuthentication:(BOOL)addAuth
{
    if(addAuth) {
        if(!self.auth.username) {
            [self broadcastServerOperationFailedWithError:@"Unknown username"];
            return;
        }
        if(!self.auth.authToken) {
            [self broadcastServerOperationFailedWithError:@"Missing authorization token. Please try logging in again"];
            return;
        }
        NSMutableDictionary *authData = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.auth.username, self.auth.authToken, nil] forKeys:[NSArray arrayWithObjects:@"username", SERVER_AUTH_TOKEN_KEY, nil]];
        [authData addEntriesFromDictionary:requestData];
        requestData = authData;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postData = [requestData urlEncodedString];
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)makeGetRequestWithUrl:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

+ (NSURL *)urlForPageName:(NSString *)page
{
    return [[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:page];
}

@end
