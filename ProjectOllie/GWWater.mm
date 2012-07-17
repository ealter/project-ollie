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

@synthesize waterHeight = _waterHeight;

-(id)init
{
    if (self = [super init]) {
        
        
        
        
        
        
        shader_ = [[CCGLProgram alloc]
                  initWithVertexShaderFilename:@"WaterShader.vsh"
                  fragmentShaderFilename:@"HMVectorNode.fsh"
                  ];
     //   GLchar *water_vsh = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WaterShader" ofType:@"vsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
     //   shader_ = [[CCGLProgram alloc] initWithVertexShaderByteArray:water_vsh fragmentShaderByteArray:<#(const GLchar *)#>];
        
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
