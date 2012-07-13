//
//  GWWater.m
//  ProjectOllie
//
//  Created by Lion User on 7/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWWater.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "CCActionCatmullRom.h"
#import "cocos2d.h"
#import "GameConstants.h"

#define pointCount 256

static CCGLProgram *shader_ = nil;

typedef struct Vertex {CGPoint vertex, texcoord;} Vertex;

@interface GWWater (){
    //Array of CGPoints to hold water shape
    Vertex *waterPoly;
}

@property float waterHeight;

@end


@implementation GWWater

@synthesize waterHeight = _waterHeight;

-(id)init
{
    if (self = [super init]) {
        //Code to make the water polygon
        waterPoly = new Vertex[pointCount];
        int width = [CCDirector sharedDirector].winSize.width;
        int height = [CCDirector sharedDirector].winSize.height;
        for (int i=0; i<pointCount; i++) {
            waterPoly[i].vertex.x = pointCount/(2*width)-width/2;
            waterPoly[i].texcoord = ccp(0, i%2);
            if (i%2) {
                waterPoly[i].vertex.y = -height/2;
            } else {
                waterPoly[i].vertex.y = height/8;
            }
        }
        
        //Shader stufff
        GLchar *water_vsh = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WaterShader" ofType:@"vsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        shader_ = [[CCGLProgram alloc] initWithVertexShaderByteArray:water_vsh fragmentShaderByteArray:ccPositionColor_frag];
        [shader_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [shader_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        [shader_ link];
        [shader_ updateUniforms];
        
        //[self ccDrawSolidPoly:verts numPoints:4+numVertices withColor:ccc4f(0, 0, 255, 1)];
    }
    return self;
}

-(void) ccDraw
{    
	[shader_ use];
	[shader_ setUniformForModelViewProjectionMatrix];
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, waterPoly);
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei) pointCount);
}

//TODO: fix these stubs
- (float)getParallaxRatio
{
    return 1;
}

- (bool)isBounded
{
    return YES;
}

@end
