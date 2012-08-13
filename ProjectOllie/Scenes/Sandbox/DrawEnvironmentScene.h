//
//  DrawEnvironmentScene.h
//  ProjectOllie
//
//  Created by Steve "The Best" Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "EnvironmentScene.h"

@interface DrawEnvironmentScene : EnvironmentScene

//Create empty environment for drawing new land
-(id) init;

//For editing land
-(id) initWithEnvironment:(GWEnvironment *)environment;

@end
