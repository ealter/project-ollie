//
//  PlayerSearch.h
//  ProjectOllie
//
//  Created by Eliot Alter on 8/3/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "ServerMatchmakingAPI.h"

@interface PlayerSearch : ServerMatchmakingAPI

- (void)searchForPlayerWithUsername:(NSString *)username;

@end
