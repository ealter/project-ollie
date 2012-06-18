//
//  ServerAPI.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAPI.h"
#import "Authentication.h"

@implementation ServerAPI

@synthesize auth = _auth;

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

- (void)dealloc
{
    [data_ release];
    [super dealloc];
}

@end
