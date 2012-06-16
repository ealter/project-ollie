//
//  Login.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/16/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Login_Delegate <NSObject>
@optional
- (void)loginSucceeded;
- (void)loginFailedWithError:(NSString *)error;
@end

@interface Login : NSObject

@property (nonatomic, assign) id<Login_Delegate> delegate;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password;

@end
