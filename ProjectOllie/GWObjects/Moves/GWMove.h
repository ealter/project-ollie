//
//  GWMove.h
//  ProjectOllie
//
//  Created by Eliot Alter on 7/23/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kGWMovesFPS = 20
};

@interface GWMove : NSObject {
    NSTimer *updateTimer_;
    float currentTime_;
}

@property (nonatomic, strong) NSMutableArray *moves;

- (NSString *)serialize;
- (void)deserialize:(NSString *)data;

//Timer stuff (for key framing automatically)
- (void)startMove;
- (void)stopMove;

@end
