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

/* Properties */

@property (nonatomic) Setting setting;

@property (strong, nonatomic) Terrain* terrain;

@property (strong, nonatomic) GWWater* frontWater;

@property (strong, nonatomic) GWWater* backWater;

@property (strong, nonatomic) CCLayer* actionLayer;     // Layer at z=0 above land but behind front water and particles, where action happens

@property (strong, nonatomic) CCLayer* backdrop;        // The farthest back layer at the max z we care about

//Other background layers

//Particle layers

/* Methods */

//Load all of the textures
+(void) initialize;

-(id) initWithSetting:(Setting)setting;

-(id) initWithSetting:(Setting)setting terrain:(Terrain*)terrain;



@end
