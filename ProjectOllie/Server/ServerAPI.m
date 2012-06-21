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

@implementation ServerAPI

@synthesize auth = _auth;
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
    if(!_auth)
        _auth = [Authentication mainAuth];
    return _auth;
}

- (void)broadcastServerOperationSucceeded
{
    if([self.delegate respondsToSelector:@selector(serverOperationSucceeded)])
        [self.delegate serverOperationSucceeded];
}

- (void)broadcastServerOperationFailedWithError:(NSString *)error
{
    if([self.delegate respondsToSelector:@selector(serverOperationFailedWithError:)])
        [self.delegate serverOperationFailedWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [data_ appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                 message:[error localizedDescription]
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                       otherButtonTitles:nil] autorelease] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(!data_) {
        [self broadcastServerOperationFailedWithError:nil];
        return;
    }
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data_ options:kNilOptions error:&error];
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
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)makeServerRequestWithData:(NSDictionary *)requestData url:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postData = [requestData urlEncodedString];
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLConnection alloc]initWithRequest:request delegate:self] release];
}

+ (NSURL *)urlForPageName:(NSString *)page
{
    return [[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:page];
}

- (void)dealloc
{
    [data_ release];
    [super dealloc];
}

@end
