//
//  MaskedSprite.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/11/12.
//  Copyright (c) 2012 hi ku LLC. All rights reserved.
//

#import "MaskedSprite.h"
#import "cocos2d.h"
#import "CCGLProgram.h"

#define INITIAL_ALPHA 0.0
#define COVERED_ALPHA 1.0

const GLchar * mask_frag =
#import "TerrainShader.h"

@implementation MaskedSprite

- (id)initWithFile:(NSString *)file
{
    self = [super initWithFile:file];
    if (self) {
        // 1
        //TODO: change pixelFormat to kCCTexture2DPixelFormat_RGB5A1
        _maskTexture = [CCRenderTexture renderTextureWithWidth:self.textureRect.size.width height:self.textureRect.size.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [_maskTexture clear:0 g:0 b:0 a:INITIAL_ALPHA];
        
        // 2
        self.shaderProgram = [[[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert                                                                         
                                                         fragmentShaderByteArray:mask_frag] autorelease];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 3
        [shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [shaderProgram_ addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
        [shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 4
        [shaderProgram_ link];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 5
        [shaderProgram_ updateUniforms];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 6
        _textureLocation = glGetUniformLocation( shaderProgram_->program_, "u_texture");
        _maskLocation = glGetUniformLocation( shaderProgram_->program_, "u_mask");
        
        CHECK_GL_ERROR_DEBUG();
    }
    return self;
}

-(void) draw {
    CCTexture2D *mask = [_maskTexture texture];
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex );
    // 1
    ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    ccGLUseProgram( shaderProgram_->program_ );
    [shaderProgram_ setUniformForModelViewProjectionMatrix];
    
    // 2
    glActiveTexture(GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D,  [texture_ name] );
    glUniform1i(_textureLocation, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture( GL_TEXTURE_2D,  [mask name] );
    glUniform1i(_maskLocation, 1);
    
    // 3
#define kQuadSize sizeof(quad_.bl)
    char *offset = (char*)&quad_;
    
    // vertex
    NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
    // texCoods
    diff = offsetof( ccV3F_C4B_T2F, texCoords);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
    // color
    diff = offsetof( ccV3F_C4B_T2F, colors);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    // 4
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glActiveTexture(GL_TEXTURE0);
}

- (void)drawPolygon:(const CGPoint *)poly numPoints:(NSUInteger)numberOfPoints
{
    [_maskTexture begin];
    ccColor4F color = {0, 0, 0, COVERED_ALPHA};
    ccDrawSolidPoly(poly, numberOfPoints, color);
    
    [_maskTexture end];
}

- (BOOL)saveMaskToFile:(NSString *)fileName
{
    return [_maskTexture saveToFile:fileName format:kCCImageFormatPNG];
}

@end
