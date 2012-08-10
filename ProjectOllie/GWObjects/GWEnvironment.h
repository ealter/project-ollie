//
//  GWEnvironment.h
//  ProjectOllie
//
//  Created by l. ion battery Steve Gregory on 8/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#import "CCLayer.h"
#import "Terrain.h"
#import "GWWater.h"

typedef enum settingTypes
{
    dirt = 0,   //Dirt, leaves, jungle
    rocks = 1,  //Rocks, rain, jungle
    ice = 2,    //Ice, snow, mountains
    lava = 3   //Lava, dust, volcanoes
} Setting;

@interface GWEnvironment : CCLayer

/* Properties (layers are in order of greater Z from camera) */

@property (nonatomic) Setting setting;

@property (strong, nonatomic) GWWater* frontWater;      // Water that is in front of everything else

@property (strong, nonatomic) GWPerspectiveLayer* actionLayer;     // Layer at z=0 where action should happen in the environment, owning class adds to this, contains terrain

@property (strong, nonatomic) Terrain* terrain;         // Contains everything you need for your very own terrain with features like rectangles

@property (strong, nonatomic) GWWater* backWater;       // That other water

@property (strong, nonatomic) GWPerspectiveLayer* backgroundNear;  // Closest background layer

@property (strong, nonatomic) GWPerspectiveLayer* backgroundFar;   // Farther background layer

@property (strong, nonatomic) GWPerspectiveLayer* backdrop;        // The farthest back layer at the max z we care about

//Other background layers

//Particle layers

/* Methods */

//Load all of the textures
+(void) initialize;

//Blank terrain with the default setting
-(id) init;

-(id) initWithSetting:(Setting)setting terrain:(Terrain*)terrain camera:(GWCamera*)camera;

-(id) setCamera:(GWCamera*)camera;



@end
