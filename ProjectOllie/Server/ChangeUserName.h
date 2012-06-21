//
//  ChangeUserName.h
//  ProjectOllie
//
//  Created by Eliot Alter on 6/20/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerAPI.h"

@interface ChangeUserName : ServerAPI

- (void)changeUserNameTo:(NSString *)newUsername;

@end
