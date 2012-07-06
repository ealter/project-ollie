//
//  ServerAPI.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Authentication;

#define SERVER_AUTH_TOKEN_KEY @"auth_token"
#define SERVER_ERROR_KEY @"error"

#ifndef SERVER_IS_DEV
#define SERVER_IS_DEV 1
#endif

#ifndef DOMAIN_NAME
 #if SERVER_IS_DEV
 #define DOMAIN_NAME @"http://dev.gorillawarfaregame.com"
 #else
 #define DOMAIN_NAME @"http://www.gorillawarfaregame.com"
 #endif /* SERVER_IS_DEV */
#endif /* DOMAIN_NAME */

@protocol ServerAPI_delegate <NSObject>

- (void)serverOperationSucceeded;
- (void)serverOperationFailedWithError:(NSString *)error;

@end

/* Used to handle interactions with the server that would otherwise be pretty boilerplate. This is an abstract class.
 */
@interface ServerAPI : NSObject <NSURLConnectionDataDelegate> {
    NSMutableData *data_;
}

@property (nonatomic, readonly, strong) Authentication *auth;
@property (nonatomic, assign) id<ServerAPI_delegate> delegate;

//Protected methods
- (void)broadcastServerOperationSucceeded;
- (void)broadcastServerOperationFailedWithError:(NSString *)error;
- (void)serverReturnedResult:(NSDictionary *)result; //Called only if the server did not return an error. Subclasses must override this
- (void)makeServerRequestWithData:(NSDictionary *)requestData url:(NSURL *)url;

+ (NSURL *)urlForPageName:(NSString *)page;

@end
