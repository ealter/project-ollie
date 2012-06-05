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
    CGSize worldDimensions;

}

@property (assign, nonatomic) bool isChanging;
@property (strong, nonatomic) CCNode* target;

-(id)initWithSubject:(id)subject worldDimensions:(CGSize)wd;
-(void)followNode:(CCNode*)focused;
-(void)panTo:(CGPoint)location;
-(void)revertTo:(CCNode*)center;

@end
