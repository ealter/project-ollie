//
//  GWCamera.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNode.h"

@interface GWCamera : NSObject
{
    CCNode* subject_;
}

@property (assign, nonatomic) bool isChanging;
@property (strong, nonatomic) CCNode* target;

-(id)initWithSubject:(id)subject;
-(void)followNode:(CCNode*)focused;
-(void)panTo:(CGPoint)location;
-(void)revertTo:(CCNode*)center withWidth:(float)width Height:(float)height;

@end
