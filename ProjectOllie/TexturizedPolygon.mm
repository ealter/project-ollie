//
//  TexturizedPolygon.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TexturizedPolygon.h"

@interface TexturizedPolygon (privateMethods)

/**
 Recalculate the texture coordinates. Called when setTexture is called.
 */
-(void) calculateTextureCoordinates;

/**
 * Calculate vertices of triangle strip.
 */
-(NSArray*) triangulateVertices:(NSArray*)vertices;

@end

@implementation TexturizedPolygon

@synthesize polygon = _polygon;
@synthesize tristrip = _tristrip;
@synthesize texture = _texture;


/**
 Returns an autoreleased polygon.  Default triangulator is used (Ratcliff's).
 */
+(id) filledPolygonWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture {
    return [[[TexturizedPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture] autorelease];
}



-(id) initWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture2D *)fillTexture {
    if( (self=[super init])) {
        [self setPoints:polygonPoints];
		self.texture = fillTexture;
        
	}
	
	return self;
}

- (NSArray *) triangulateVertices:(NSArray *)vertices {
    
    gpc_vertex_list vl;
    vl.num_vertices = [vertices count];
    vl.vertex = new gpc_vertex[vl.num_vertices];
    
    int counter = 0;
    for (NSValue *value in vertices) {
        CGPoint point = [value CGPointValue];
        gpc_vertex p;
        p.x = point.x;
        p.y = point.y;
        vl.vertex[counter] = p;
        counter++;
    }
    
    self.polygon->contour = &vl;
    
    // Triangulate results
    std::vector<CGPoint> triangulatedPoints;
    gpc_polygon_to_tristrip(self.polygon,self.tristrip);

    
    
    int triangulatedPointCount = triangulatedPoints.size();
    NSMutableArray *triangulatedPointsArray = [NSMutableArray arrayWithCapacity:triangulatedPointCount];
    for (int i = 0; i < triangulatedPointCount; i++) {
        NSValue *triangulatedPointValue = [NSValue valueWithCGPoint:CGPointMake(self.tristrip->strip->vertex[i].x, self.tristrip->strip->vertex[i].x)];
        [triangulatedPointsArray addObject:triangulatedPointValue];
    }
    return triangulatedPointsArray;
    
}


-(void) setPoints: (NSArray *) points {
    if (areaTrianglePoints)
        free(areaTrianglePoints);
    if (textureCoordinates)
        free(textureCoordinates);
    
    NSArray *triangulatedPoints = [self triangulateVertices:points];
    
    areaTrianglePointCount = [triangulatedPoints count];
    areaTrianglePoints = (CGPoint *) malloc(sizeof(CGPoint) * areaTrianglePointCount);
    textureCoordinates = (CGPoint *) malloc(sizeof(CGPoint) * areaTrianglePointCount);
    
    for (int i = 0; i < areaTrianglePointCount; i++) {
        areaTrianglePoints[i] = [[triangulatedPoints objectAtIndex:i] CGPointValue];
    }
    
    [self calculateTextureCoordinates];
    
}

-(void) calculateTextureCoordinates {
	for (int j = 0; j < areaTrianglePointCount; j++) {
		textureCoordinates[j] = ccpMult(areaTrianglePoints[j], 1.0f/texture.pixelsWide);
	}
}

-(void) draw {
	// we have a pointer to vertex points so enable client state
	/*glBindTexture(GL_TEXTURE_2D, self.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, areaTrianglePoints);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, areaTrianglePointCount);*/
    
    
	
}

-(void) updateBlendFunc {
	// it's possible to have an untextured sprite
	if( !texture || ! [texture hasPremultipliedAlpha] ) {
		blendFunc.src = GL_SRC_ALPHA;
		blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		//[self setOpacityModifyRGB:NO];
	} else {
		blendFunc.src = CC_BLEND_SRC;
		blendFunc.dst = CC_BLEND_DST;
		//[self setOpacityModifyRGB:YES];
	}
}

-(void) setBlendFunc:(ccBlendFunc)blendFuncIn {
	blendFunc = blendFuncIn;
}

-(ccBlendFunc) blendFunc {
	return blendFunc;
}

-(void) setTexture:(CCTexture2D *) texture2D {
	
	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");
	
	[texture release];
	texture = [texture2D retain];
	ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT };
	[texture setTexParameters: &texParams];
	
	[self updateBlendFunc];
	[self calculateTextureCoordinates];
}

-(CCTexture2D *) texture {
	return texture;
}

-(void) dealloc {
    [super dealloc];
	free(areaTrianglePoints);
	free(textureCoordinates);
	[texture release]; texture = nil;
    
}

@end
