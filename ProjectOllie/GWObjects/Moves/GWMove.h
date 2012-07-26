//
//  GWMove.h
//  ProjectOllie
//
//  Created by Eliot Alter on 7/23/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h" //Needs to inherit from CCNode so that we can use scheduleUpdate

@interface GWMove : CCNode {
    float currentTime_;
    NSMutableArray *moves_;
}

- (NSString *)serialize;
- (void)deserialize:(NSString *)data;

//Timer stuff (for key framing automatically)
- (void)startMove; //Start recording the move
- (void)stopMove;  //Stop  recording the move

@end
