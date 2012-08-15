//
//  GWEnvironment.h
//  ProjectOllie
//
//  Created by Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "CCLayer.h"
#import "Terrain.h"
#import "GWWater.h"

typedef enum EnvironmentSetting
{
    environment_dirt = 0,   //Dirt, leaves, jungle
    environment_rocks,      //Rocks, rain, jungle
    environment_ice,        //Ice, snow, mountains
    environment_lava        //Lava, dust, volcanoes
} EnvironmentSetting;

@interface GWEnvironment : CCNode

/* Properties (layers are in order of greater Z from camera) */

@property (nonatomic) EnvironmentSetting setting;

@property (strong, nonatomic) GWWater* frontWater;      // Water that is in front of everything else

@property (strong, nonatomic) GWPerspectiveLayer* actionLayer;     // Layer at z=0 where action should happen in the environment, owning class adds to this, contains terrain

@property (strong, nonatomic) Terrain* terrain;         // Contains everything you need for your very own terrain with features like rectangles

@property (strong, nonatomic) GWWater* backWater;       // That other water

@property (strong, nonatomic) GWPerspectiveLayer* backgroundNear;  // Closest background layer

@property (strong, nonatomic) GWPerspectiveLayer* backgroundFar;   // Farther background layer

@property (strong, nonatomic) GWPerspectiveLayer* backdrop;        // The farthest back layer at the max z we care about

//Particle layers not included yet

/* Methods */

//Blank terrain with the default setting
-(id) init;

-(id) initWithSetting:(EnvironmentSetting)setting terrain:(Terrain*)terrain camera:(GWCamera*)camera;

-(void) setCamera:(GWCamera*)camera;

@end
