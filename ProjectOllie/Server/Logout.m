//
//  Logout.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/18/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "Logout.h"
#import "Authentication.h"
#import "NSDictionary+URLEncoding.h"
#import "FacebookLogin.h"

@implementation Logout

- (void)logout
{
    Authentication *auth = [Authentication mainAuth];
    if(auth.username && auth.authToken) {
        NSURL *logoutURL = [[[NSURL URLWithString:DOMAIN_NAME] URLByAppendingPathComponent:@"accounts"] URLByAppendingPathComponent:@"logout"];
        NSDictionary *requestData = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:auth.username, auth.authToken, nil] forKeys:[NSArray arrayWithObjects:@"username", SERVER_AUTH_TOKEN_KEY, nil]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:logoutURL];
        request.HTTPMethod = @"POST";
        NSString *postData = [requestData urlEncodedString];
        [requestData release];
        request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:nil];
        [connection release];
    }
    auth.authToken = nil;
    [auth.facebookLogin logout];
}

//TODO: call the delegate methods

@end
