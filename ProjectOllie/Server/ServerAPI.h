//
//  ServerAPI.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Authentication;

/* Used to handle interactions with the server that would otherwise be pretty boilerplate. Subclasses should implement - (void)connectionDidFinishLoading:(NSURLConnection *)connection
 */
@interface ServerAPI : NSObject <NSURLConnectionDataDelegate> {
    NSMutableData *data_;
}

@property (nonatomic, readonly, retain) Authentication *auth;

@end
