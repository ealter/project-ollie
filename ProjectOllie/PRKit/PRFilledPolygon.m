/*
 PRFilledPolygon.m
 
 PRKit:  Precognitive Research additions to Cocos2D.  http://cocos2d-iphone.org
 Contact us if you like it:  http://precognitiveresearch.com
 
 Created by Andy Sinesio on 6/25/10.
 Copyright 2011 Precognitive Research, LLC. All rights reserved.
 
 This class fills a polygon as described by an array of NSValue-encapsulated points with a texture.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "PRFilledPolygon.h"
#import "PRRatcliffTriangulator.h"
#import "ccGLStateCache.h"
#import "ccMacros.h"
#import "CCTexture2D.h"
#import "CCTextureCache.h"
#import "CCGLProgram.h"
#import "CCConfiguration.h"
#import "ccTypes.h"
#import "CCShaderCache.h"

@interface PRFilledPolygon (privateMethods)

/**
 Recalculate the texture coordinates. Called when setTexture is called.
*/
-(void) calculateTextureCoordinates;

@end

@implementation PRFilledPolygon

@synthesize triangulator;


/**
 Returns an autoreleased polygon.  Default triangulator is used (Ratcliff's).
 */
+(id) filledPolygonWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture {
    return [[[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture] autorelease];
}

/**
 Returns an autoreleased filled poly with a supplied triangulator.
 */
+(id) filledPolygonWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture2D *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    return [[[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:polygonTriangulator] autorelease];
}

-(id) initWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture {
    return [self initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:[[[PRRatcliffTriangulator alloc] init] autorelease]];
}

-(id) initWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture2D *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    if( (self=[super init])) {
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
        self.triangulator = polygonTriangulator;
        
        [self setPoints:polygonPoints];
		self.texture = fillTexture;
        
	}
	
	return self;
}

-(void) setPoints: (NSArray *) points {
    if (areaTrianglePoints)
        free(areaTrianglePoints);
    if (textureCoordinates)
        free(textureCoordinates);
    
    NSArray *triangulatedPoints = [triangulator triangulateVertices:points];
    
    areaTrianglePointCount = [triangulatedPoints count];
    areaTrianglePoints = (ccVertex2F *) malloc(sizeof(ccVertex2F) * areaTrianglePointCount);
    textureCoordinates = (ccVertex2F *) malloc(sizeof(ccVertex2F) * areaTrianglePointCount);

    for (int i = 0; i < areaTrianglePointCount; i++) {
        CGPoint p = [[triangulatedPoints objectAtIndex:i] CGPointValue];
        areaTrianglePoints[i].x = p.x;
        areaTrianglePoints[i].y = p.y;
    }
    
    [self calculateTextureCoordinates];

}

-(void) calculateTextureCoordinates {
	for (int j = 0; j < areaTrianglePointCount; j++) {
		textureCoordinates[j].x = areaTrianglePoints[j].x * 1.0f/texture.pixelsWide;
		textureCoordinates[j].y = areaTrianglePoints[j].y * 1.0f/texture.pixelsHigh;
	}
}

-(void) draw {
    
 //  NSString* toLog = [NSString stringWithFormat:@"%@%f%@%f",@"Drawing at X: ",areaTrianglePoints[0].x, @" and Y: ",areaTrianglePoints[0].y];
 //  NSLog(toLog);    
    CC_PROFILER_START(@"PRFilledPolygon - draw");
    
    CC_NODE_DRAW_SETUP();
    
    ccGLBlendFunc( blendFunc.src, blendFunc.dst );
    
	// we have a pointer to vertex points so enable client state
	ccGLBindTexture2D( [self.texture name] );
	
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
    
#define kPointSize sizeof(ccVertex2F)
    // vertex
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, kPointSize, areaTrianglePoints);
    
	// texCoods
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kPointSize, textureCoordinates);
    
	glDrawArrays(GL_TRIANGLES, 0, areaTrianglePointCount);
	//glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
    CC_INCREMENT_GL_DRAWS(1);
	
    CC_PROFILER_STOP(@"PRFilledPolygon - draw");
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
    [triangulator release]; triangulator = nil;

}

@end
