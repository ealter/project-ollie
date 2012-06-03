//
//  Terrain.h
//  ProjectOllie
//
//  Created by Lion User on 6/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    inside,
    outside	 
} LandType;


@interface Terrain : CCNode {
    NSMutableArray *viewPolygons;
    
}

//+ (id) generateRandomWith


@end
