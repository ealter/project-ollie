//
//  ScrollingBackground.h
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//



#import "CCLayer.h"
#import "GWCamera.h"

@interface Background : CCLayer <CameraObject> 

@property (assign, nonatomic) float scrollSpeed; /* In pixels/second. Positive means left to right, negative means right to left. */
@property (nonatomic, strong) NSArray *imageNames; //An array of NSStrings

/* Note: It is fine to call the regular init method instead of this one. If you do that, make sure to set the imageNames at some point or else this class will not display anything. */
- (id)initWithSpeed:(float)speed images:(NSArray *)imageNames;

@end
