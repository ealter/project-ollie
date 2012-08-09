//
//  EnvironmentScene.h
//  ProjectOllie
//
//  Created by lion hunter Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "CCScene.h"
#import "GWEnvironment.h"
#import "GWCamera.h"

@interface EnvironmentScene : CCScene


@property (strong, nonatomic) GWEnvironment* environment;   //All of the environment layers and data, contains the action layer

@property (strong, nonatomic) GWCamera* camera;             //Camera used to transform environment layers

@property (strong, nonatomic) CCLayer* worldHUD;            //Heads up layer transformed with the action layer but above the environment

@property (strong, nonatomic) CCLayer* screenHUD;           //Heads up layer in screen space, above everything



@end
