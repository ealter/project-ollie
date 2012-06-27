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
#import "HMVectorNode.h"

#define INITIAL_RED 0.0
#define COVERED_RED 1.0
#define STROKE_BLUE 1.0
#define PIXEL_FORMAT kCCTexture2DPixelFormat_RGBA8888


@interface MaskedSprite (){
    
    HMVectorNode* pr;

}

@property (nonatomic, strong) CCRenderTexture *maskTexture;
@property (nonatomic) GLuint textureWidthLocation;
@property (nonatomic) GLuint textureHeightLocation;
@property (nonatomic) GLuint textureLocation;
@property (nonatomic) GLuint maskLocation;
@property (nonatomic) GLuint screenWidthLocation;
@property (nonatomic) GLuint screenHeightLocation;


@end

@implementation MaskedSprite

@synthesize maskTexture = _maskTexture;
@synthesize textureWidthLocation = _textureWidthLocation, textureHeightLocation = _textureHeightLocation, textureLocation = textureLocation_, maskLocation = maskLocation_, screenWidthLocation = screenWidthLocation_, screenHeightLocation = screenHeightLocation_;

- (id)initWithFile:(NSString *)file size:(CGSize)size
{
    self = [super initWithFile:file rect:CGRectMake(0,0,size.width,size.height)];
    if (self) {
    
        //set up rendering paramters
        //texture must be power of 2
        ccTexParams params = {GL_NICEST, GL_NICEST, GL_REPEAT, GL_REPEAT};
        [self.texture setTexParameters: &params];
        [self.texture setAntiAliasTexParameters];
        
        
        [self.maskTexture.sprite.texture setAntiAliasTexParameters];
        [self.maskTexture.sprite.texture setTexParameters:&params];
        self->pr = [[HMVectorNode alloc] init];

        // Set up the mask texture with appropriate texture coordinates
        self.maskTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height pixelFormat:PIXEL_FORMAT];
        [self clear];
  
        //makes 0,0,1,1 texturecoordinates
        quad_.bl.texCoords.u = 0;
		quad_.bl.texCoords.v = 0;
		quad_.br.texCoords.u = 1;
		quad_.br.texCoords.v = 0;
		quad_.tl.texCoords.u = 0;
		quad_.tl.texCoords.v = 1;
		quad_.tr.texCoords.u = 1;
		quad_.tr.texCoords.v = 1;
        
        // 1
        //TODO: change pixelFormat to kCCTexture2DPixelFormat_RGB5A1
        self.maskTexture = [CCRenderTexture renderTextureWithWidth:self.textureRect.size.width height:self.textureRect.size.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [self.maskTexture clear:INITIAL_RED g:0 b:0 a:1];
        
        // 2
        NSError *error = nil;
        GLchar *mask_frag = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TerrainShader" ofType:@"frag"] encoding:NSUTF8StringEncoding error:&error] UTF8String];
        if(error) {
            DebugLog(@"The error: %@", error);
        }
        assert(mask_frag);
        self.shaderProgram = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert fragmentShaderByteArray:mask_frag];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 3
        [shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [shaderProgram_ addAttribute:kCCAttributeNameColor    index:kCCVertexAttrib_Color];
        [shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 4
        [shaderProgram_ link];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 5
        [shaderProgram_ updateUniforms];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 6
        self.textureLocation       = glGetUniformLocation( shaderProgram_->program_, "u_texture");
        self.maskLocation          = glGetUniformLocation( shaderProgram_->program_, "u_mask");
        self.textureWidthLocation  = glGetUniformLocation( shaderProgram_->program_, "textureWidth");
        self.textureHeightLocation = glGetUniformLocation( shaderProgram_->program_, "textureHeight");
        self.screenWidthLocation   = glGetUniformLocation( shaderProgram_->program_, "screenWidth");
        self.screenHeightLocation  = glGetUniformLocation( shaderProgram_->program_, "screenHeight");
        
        CHECK_GL_ERROR_DEBUG();
    }
    return self;
}

-(void) draw {
  
    
    CCTexture2D *mask = self.maskTexture.sprite.texture;
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex );
    // 1
    ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ccGLUseProgram( shaderProgram_->program_ );
    [shaderProgram_ setUniformForModelViewProjectionMatrix];
    
    // 2
    glActiveTexture(GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D,  [texture_ name] );
    glUniform1i(self.textureLocation, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture( GL_TEXTURE_2D,  [mask name] );
    glUniform1i(self.maskLocation, 1);
    
    glUniform1f(self.textureWidthLocation, self.texture.pixelsWide);
    glUniform1f(self.textureHeightLocation, self.texture.pixelsHigh);
    
    glUniform1f(self.screenWidthLocation, self.contentSize.width);
    glUniform1f(self.screenHeightLocation, self.contentSize.height);
   
    
    // 3
#define kQuadSize sizeof(quad_.bl)
    
    // vertex
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, &quad_.tl.vertices);
    
    // texCoods
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, &quad_.tl.texCoords);
    
    // color
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, &quad_.tl.colors);
    
    // 4
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glActiveTexture(GL_TEXTURE0);
    
    
}

-(void)drawCircleAt:(CGPoint)center withRadius:(float)radius Additive:(bool)add
{

    ccColor4F color;
    if(add)
        color = ccc4f(COVERED_RED,0,0,1);
    else
        color = ccc4f(INITIAL_RED,0,0,1);
    [self.maskTexture begin];
    [self->pr drawDot:center radius:(radius+.5f) color:color];
    [self->pr visit];
    [self->pr clear];
    [self.maskTexture end];
}


- (void)drawPolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints Additive:(bool)add
{
    
    ccColor4F color;
    if(add)
        color = ccc4f(COVERED_RED,0,0,1);
    else
        color = ccc4f(INITIAL_RED,0,0,1);
    
    [self.maskTexture begin];
    [self->pr drawPolyWithVerts:poly count:numberOfPoints width:1 fill:color line:color];
    [self->pr visit];
    [self->pr clear];
    [self.maskTexture end];
}

-(void)drawLines:(const CGPoint*)poly numPoints:(NSUInteger)num{
    ccColor4F color = ccc4f(COVERED_RED,0,STROKE_BLUE,1);
    
    [self.maskTexture begin];
    for(int i = 0; i < num-1; i++)
    {
       [self->pr drawSegmentFrom:poly[i] to:poly[i+1] radius:2.f color:color]; 
    }
    [self->pr drawSegmentFrom:poly[num-1] to:poly[0] radius:2.f color:color];
    [self->pr visit];
    [self->pr clear];
    [self.maskTexture end];
}


- (BOOL)saveMaskToFile:(NSString *)fileName
{
    if(PIXEL_FORMAT != kCCTexture2DPixelFormat_RGBA8888)
        return NO;
    return [self.maskTexture saveToFile:fileName format:kCCImageFormatPNG];
}

- (void)clear{
    [self.maskTexture clear:INITIAL_RED g:0 b:0 a:1];
}

@end
