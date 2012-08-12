//
//  MaskedSprite.m
//  ProjectOllie
//
//  Created by Eliot Alter on 6/11/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "MaskedSprite.h"
#import "cocos2d.h"
#import "CCGLProgram.h"
#import "HMVectorNode.h"
#import "CCTexture2DMutable.h"

static const ccColor4F kInitialColor = {0,0,0,1};
static const ccColor4F kCoveredColor = {1,0,0,1};

static const CCTexture2DPixelFormat kPixelFormat = kCCTexture2DPixelFormat_RGB5A1;
#define SCALE_RATIO 1.0

@interface MaskedSprite (){
    HMVectorNode* pr;
}

@property (nonatomic, strong) CCRenderTexture *maskTexture;
@property (nonatomic, strong) CCRenderTexture *renderTexture;
@property (nonatomic) GLuint textureWidthLocation;
@property (nonatomic) GLuint textureHeightLocation;
@property (nonatomic) GLuint textureLocation;
@property (nonatomic) GLuint maskLocation;
@property (nonatomic) GLuint screenWidthLocation;
@property (nonatomic) GLuint screenHeightLocation;

- (void)drawCircleAt:(CGPoint)center radius:(float)radius color:(ccColor4F)color;
- (void)drawPolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints color:(ccColor4F)color;
- (void)drawPoints:(NSArray *)points color:(ccColor4F)color;
- (void)updateMask;

@end

@implementation MaskedSprite

@synthesize maskTexture = _maskTexture, renderTexture = _renderTexture;
@synthesize textureWidthLocation = _textureWidthLocation, textureHeightLocation = _textureHeightLocation, textureLocation = textureLocation_, maskLocation = maskLocation_, screenWidthLocation = screenWidthLocation_, screenHeightLocation = screenHeightLocation_;

- (id)initWithFile:(NSString *)file size:(CGSize)size
{
    self = [super initWithFile:file rect:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        
        //set up rendering paramters
        //texture must be power of 2
        ccTexParams params = {GL_NICEST, GL_NICEST, GL_REPEAT, GL_REPEAT};
        [self.texture setTexParameters: &params];
        [self.texture setAntiAliasTexParameters];
        
        self->pr = [[HMVectorNode alloc] init];
        
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
        self.renderTexture = [CCRenderTexture renderTextureWithWidth:self.textureRect.size.width height:self.textureRect.size.height pixelFormat:kPixelFormat];
        ccTexParams renderParams = {GL_NICEST,GL_NICEST,GL_CLAMP_TO_EDGE,GL_CLAMP_TO_EDGE};
        [self.renderTexture.sprite.texture setTexParameters:&renderParams];
        [self.renderTexture clear:0 g:0 b:0 a:0];
        self.maskTexture   = [CCRenderTexture renderTextureWithWidth:self.textureRect.size.width height:self.textureRect.size.height pixelFormat:kPixelFormat];
        [self.maskTexture clear:kInitialColor.r g:kInitialColor.g b:kInitialColor.b a:kInitialColor.a];
        
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
        
        
        /* Handles the CCRenderTexture positions/scales */
        /*
         //Rescale back to greater size
         self.renderTexture.scale = 2;
         
         //On the lower left quarter of the screen.
         [self setPosition:ccp(size.width/4,size.height/4)];
         [self.maskTexture setPosition:ccp(size.width/4,size.height/4)];
         
         //On the center because scaled by 2 will fill the screen.
         */
        [self.renderTexture setPosition:ccp(size.width/2,size.height/2)];
    }
    return self;
}

- (void)updateMask
{
    [self.maskTexture begin];
    [self->pr visit];
    [self.maskTexture end];
    [self->pr clear];
    
    [self.renderTexture beginWithClear:0 g:0 b:0 a:0];
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
    [self.renderTexture end];
}

- (void)draw
{    
    [self.renderTexture visit];
}

- (void)addCircleAt:(CGPoint)center radius:(float)radius
{
    [self drawCircleAt:center radius:radius color:kCoveredColor];
}

- (void)removeCircleAt:(CGPoint)center radius:(float)radius
{
    [self drawCircleAt:center radius:radius color:kInitialColor];
}

- (void)drawCircleAt:(CGPoint)center radius:(float)radius color:(ccColor4F)color
{
    [self->pr setColor:color];
    [self->pr drawDot:ccpMult(center,SCALE_RATIO) radius:(radius + .5f)*SCALE_RATIO];
    [self updateMask];
}

- (void)addPolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints
{
    [self drawPolygon:poly numPoints:numberOfPoints color:kCoveredColor];
}

- (void)removePolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints
{
    [self drawPolygon:poly numPoints:numberOfPoints color:kInitialColor];
}

- (void)drawPolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints color:(ccColor4F)color
{
    [self->pr setColor:color];
    
    for(int i = 0; i < numberOfPoints; i++) {
        poly[i] = ccpMult(poly[i],SCALE_RATIO);
    }
    
    [self->pr drawPolyWithVerts:poly count:numberOfPoints width:0];
    [self updateMask];
}

- (void)addPoints:(NSArray *)points
{
    [self drawPoints:points color:kCoveredColor];
}

- (void)removePoints:(NSArray *)points
{
    [self drawPoints:points color:kInitialColor];
}

- (void)drawPoints:(NSArray *)points color:(ccColor4F)color
{
    [self->pr setColor:color];
    for(NSValue *point in points) {
        if(![point isKindOfClass:[NSValue class]]) continue;
        CGPoint p = [point CGPointValue];
        [self->pr drawDot:p radius:0.5];
    }
    [self updateMask];
}

- (BOOL)saveMaskToFile:(NSString *)fileName
{
    if(kPixelFormat != kCCTexture2DPixelFormat_RGBA8888)
        return NO;
    return [self.maskTexture saveToFile:fileName format:kCCImageFormatPNG];
}

- (void)clear
{
    [self.maskTexture clear:kInitialColor.r g:kInitialColor.g b:kInitialColor.b a:kInitialColor.a];
    [self.renderTexture clear:0 g:0 b:0 a:0];
}

@end
