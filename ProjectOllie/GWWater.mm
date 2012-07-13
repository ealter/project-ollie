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

#import "GameConstants.h"

#define pointCount 256

static CCGLProgram *shader_ = nil;

@interface GWWater (){
    //Water polygon in CGPoints
    CGPoint waterPolyPoints [pointCount];
    //GL vertex buffer object for the water points
    GLuint    waterVBO;
    //Location of the time parameter for the gl shader
    GLuint    timeLocation;
    
    
}

@property float waterHeight;
@end


@implementation GWWater

-(id)init
{
    if (self = [super init]) {
        /* Make the water triangle strip */
        
        int width = [CCDirector sharedDirector].winSize.width;
        int height = [CCDirector sharedDirector].winSize.height;
        for (int i=0; i<pointCount; i++) {
            waterPolyPoints[i].x = i*2*width/pointCount-width/2;
            if (i%2)
                waterPolyPoints[i].y = -height/2;
            else
                waterPolyPoints[i].y = height/8;
        }
        
        /* Give the triangle strip to openGL */
        glGenBuffers(1, &waterVBO);
        glBindBuffer(GL_ARRAY_BUFFER, waterVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(waterPolyPoints), waterPolyPoints, GL_STATIC_DRAW);
        
        /* Shader stuff */
        GLchar *water_vsh = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WaterShader" ofType:@"vsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        shader_ = [[CCGLProgram alloc] initWithVertexShaderByteArray:water_vsh fragmentShaderByteArray:ccPositionColor_frag];
        [shader_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [shader_ link];
        [shader_ updateUniforms];
        
    }
    
    return self;
}

-(void) ccDraw
{    
	[shader_ use];
	[shader_ setUniformForModelViewProjectionMatrix];
    
	glBindBuffer(GL_ARRAY_BUFFER, waterVBO);
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(CGPoint), 0);
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei) pointCount);
}

@end
