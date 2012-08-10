//
//  GWWater.m
//  ProjectOllie
//
//  Created by Lion Steven on 7/5/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWWater.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "CCActionCatmullRom.h"
#import "cocos2d.h"
#import "GameConstants.h"
#import "HMVectorNode.h"
#import "GWCamera.h"

const float kMetersPerWaterTile = 2.5;
enum {
    kMaxFrame = 232,
    kFramesPerSheet = 32,
    kSheets = 8
};

//static CCGLProgram *shader_ = nil;
static CCTexture2D *texture[kSheets];

@interface GWWater (){
    ccColor4F topColor;            //Wave and top of solid are this color
    ccColor4F bottomColor;         //Solid fades to this color
    
    //Wave things
    ccV2F_C4F_T2F_Quad wave;
    GLuint waveVbo;                //Vertex buffer
    int frame;                     //Increments every draw, wrapps at MAX_FRAME
    
    //Solid water things
    CCGLProgram *solidShaderProgram;
    ccV2F_C4F_T2F_Quad solid;
    GLuint solidVbo;
}

@property float waterHeight;
@end

@implementation GWWater

@synthesize waterHeight = _waterHeight; //Height in meters from (0, 0) to the top of the solid water, bottom of wave

static const float frameWidth = 512.0f;
static const float frameHeight = 32.0f;

-(id)initWithCamera:(GWCamera*)camera z:(float)z
{
    if (self = [super initWithCamera:camera z:z]) {
        
        topColor.r = 0.1f;
        topColor.g = 0.2f;
        topColor.b = 1.0f;
        topColor.a = 1.0f;
        bottomColor.r = 0.0f;
        bottomColor.g =  0.0f;
        bottomColor.b = 0.0f;
        bottomColor.a = 1.0f;
        if (z > 0)
        {
            topColor.b = 0.7f;
            //frame = MAX_FRAME/2;
        }
        
        /* Wave */
        
        _waterHeight = 0.5f;
        
        //Find how high the wave is in meters based on the meters per water tile
        float waveHeight = kMetersPerWaterTile*frameHeight/frameWidth;
        printf("\n\nwaveheight %f\n\n\n", waveHeight);
        
        //Initialize wave quad
        wave.bl.vertices.x = MIN_VIEWABLE_X;
        wave.bl.vertices.y = PTM_RATIO*_waterHeight;
        wave.tl.vertices.x = MIN_VIEWABLE_X;
        wave.tl.vertices.y = PTM_RATIO*(_waterHeight + waveHeight);
        wave.tr.vertices.x = MAX_VIEWABLE_X;
        wave.tr.vertices.y = wave.tl.vertices.y;
        wave.br.vertices.x = MAX_VIEWABLE_X;
        wave.br.vertices.y = wave.bl.vertices.y;
        
        //The x for the texcoords are constant (variable y's are calculated when drawing)
        wave.bl.texCoords.u = 0.f;
        wave.tl.texCoords.u = 0.f;
        wave.tr.texCoords.u = (MAX_VIEWABLE_X - MIN_VIEWABLE_X)/kMetersPerWaterTile/PTM_RATIO;
        wave.br.texCoords.u = wave.tr.texCoords.u;
        wave.bl.texCoords.v = 0.f;
        wave.tl.texCoords.v = 1.f;
        wave.tr.texCoords.v = 1.f;
        wave.br.texCoords.v = 0.f;
        
        wave.bl.colors = topColor;
        wave.tl.colors = topColor;
        wave.tr.colors = topColor;
        wave.br.colors = topColor;
        
        //Make the gl buffers
        glGenBuffers(1, &waveVbo);
        glBindBuffer(GL_ARRAY_BUFFER, waveVbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(wave), &wave, GL_DYNAMIC_DRAW);	
        
        //Shader
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureA8Color];
    
        
        CHECK_GL_ERROR_DEBUG();
        
        
        //Load frame sheet textures
        CCTexture2DPixelFormat oldDefault = [CCTexture2D defaultAlphaPixelFormat];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_A8];
        ccTexParams params = {GL_NICEST, GL_NICEST, GL_REPEAT, GL_REPEAT};
        for (int i = 0; i < kSheets; i++)
        {
            texture[i] = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"waterSheet%d.png", (i+1)]];
            [texture[i] setTexParameters: &params];
            assert(texture[i]);
        }
        [CCTexture2D setDefaultAlphaPixelFormat:oldDefault];
        
        CHECK_GL_ERROR_DEBUG();
        
        
        /* Solid */
        
        //Set up the points
        solid.bl.vertices.x = MIN_VIEWABLE_X;
        solid.bl.vertices.y = MIN_VIEWABLE_Y;
        solid.tl.vertices = wave.bl.vertices;
        solid.tr.vertices = wave.br.vertices;
        solid.br.vertices.x = MAX_VIEWABLE_X;
        solid.br.vertices.y = MIN_VIEWABLE_Y;
        
        solid.bl.colors = bottomColor;
        solid.br.colors = bottomColor;
        solid.tl.colors = topColor;
        solid.tr.colors = topColor;
        
        //Static gl buffer
        glGenBuffers(1, &solidVbo);
        glBindBuffer(GL_ARRAY_BUFFER, solidVbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(solid), &solid, GL_STATIC_DRAW);
        
        //Shader
        solidShaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
        
        CHECK_GL_ERROR_DEBUG();
    }
    return self;
}

-(void) draw
{
    //Equivelant for CC_NODE_DRAW_SETUP()
    ccGLEnable( glServerState_ );														
    NSAssert(shaderProgram_, @"No shader program set for node: %@");                      
	[shaderProgram_ use];																	
	[shaderProgram_ setUniformForModelViewProjectionMatrix];		
    
	ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //Update the frame
    frame = (frame+1)%kMaxFrame;
    
    //Calculate vertex coords for the current frame
    float h = frameHeight/1024.0f;
    int frameOnTexture = kFramesPerSheet - frame%kFramesPerSheet - 1;
    int sheet = frame/kFramesPerSheet;
    wave.tl.texCoords.v = frameOnTexture*h+1/1024.0f;
    wave.bl.texCoords.v = (frameOnTexture+1)*h-1/1024.0f;
    wave.tr.texCoords.v = wave.tl.texCoords.v;
    wave.br.texCoords.v = wave.bl.texCoords.v;
    
    //Bind the right texture
	ccGLBindTexture2D([texture[sheet] name]);
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    
    //Set up buffers for wave
    glBindBuffer(GL_ARRAY_BUFFER, waveVbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(wave), &wave);
    
    long offset = offsetof(ccV2F_C4F_T2F, vertices);
//    ccGLEnableVertexAttribs(kCCVertexAttrib_Position);
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(wave.bl), (void*)offset);
    
    offset = offsetof(ccV2F_C4F_T2F, colors);
//    ccGLEnableVertexAttribs(kCCVertexAttrib_Color);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(wave.bl), (void*)offset);
    
    offset = offsetof(ccV2F_C4F_T2F, texCoords);
//    ccGLEnableVertexAttribs(kCCVertexAttrib_TexCoords);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(wave.bl), (void*)offset);
    
    //Draw wave
    CHECK_GL_ERROR_DEBUG();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
 //   return;
    //Bind shader and buffer for solid quad
    [solidShaderProgram use];
    [solidShaderProgram setUniformForModelViewProjectionMatrix];
    glBindBuffer(GL_ARRAY_BUFFER, solidVbo);
    
    //Remind gl what the buffer is
    glEnableVertexAttribArray(kCCVertexAttrib_Position);
    offset = offsetof(ccV2F_C4F_T2F, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(solid.bl), (void*)offset);
    
    glEnableVertexAttribArray(kCCVertexAttrib_Color);
    offset = offsetof(ccV2F_C4F_T2F, colors);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(solid.bl), (void*)offset);
    
    //Draw solid quad
    CHECK_GL_ERROR_DEBUG();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    CC_INCREMENT_GL_DRAWS(2);
    
    //Reset to client memory because other things sometimes assume this is the case
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end
