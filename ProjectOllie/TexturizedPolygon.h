//
//  TexturizedPolygon.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "gpc.h"
#import "CCProtocols.h"
#import <vector.h>

@interface TexturizedPolygon : CCNode<CCRGBAProtocol, CCTextureProtocol>{
@private
	int areaTrianglePointCount;
    
	CCTexture2D *texture;
	ccBlendFunc blendFunc;
	
	CGPoint *areaTrianglePoints;
	CGPoint *textureCoordinates;
}

@property (nonatomic, assign) CCTexture2D *texture;
@property (nonatomic, assign) gpc_tristrip *tristrip;
@property (nonatomic, assign) gpc_polygon *polygon;

/**
 Returns an autoreleased polygon.  Default triangulator is used (Ratcliff's).
 */
+(id) filledPolygonWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture;

/**
 Initialize the polygon.  polygonPoints will be triangulated.  Default triangulator is used (Ratcliff).
 */
-(id) initWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture;


-(void) setPoints: (NSArray *) points;



@end

