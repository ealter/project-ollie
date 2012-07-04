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

#define INITIAL_RED 0.0
#define COVERED_RED 1.0
#define PIXEL_FORMAT kCCTexture2DPixelFormat_RGBA8888


@interface MaskedSprite (){
    HMVectorNode* pr;
}

@property (nonatomic, strong) NSString *textureFileName;
@property (nonatomic, strong) CCRenderTexture *maskTexture;
@property (nonatomic, strong) CCRenderTexture *renderTexture;
@property (nonatomic) GLuint textureWidthLocation;
@property (nonatomic) GLuint textureHeightLocation;
@property (nonatomic) GLuint textureLocation;
@property (nonatomic) GLuint maskLocation;
@property (nonatomic) GLuint screenWidthLocation;
@property (nonatomic) GLuint screenHeightLocation;

- (void)initWithMaskTexture:(CCRenderTexture *)maskTexture size:(CGSize)size;
- (void)drawCircleAt:(CGPoint)center radius:(float)radius red:(float)red;
- (void)drawPolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints red:(float)red;

@end

@implementation MaskedSprite

@synthesize maskTexture = _maskTexture, renderTexture = _renderTexture;
@synthesize textureWidthLocation = _textureWidthLocation, textureHeightLocation = _textureHeightLocation, textureLocation = textureLocation_, maskLocation = maskLocation_, screenWidthLocation = screenWidthLocation_, screenHeightLocation = screenHeightLocation_;
@synthesize textureFileName = _textureFileName;

#define TEXTURE_RECT_KEY      @"Texture rect"
#define TEXTURE_FILE_KEY      @"Texture file"
#define MASK_TEXTURE_FILE_KEY @"Mask texture file"
#define SIZE_FACTOR 2

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *file = [aDecoder decodeObjectForKey:TEXTURE_FILE_KEY];
    CGRect rect    = [aDecoder decodeCGRectForKey:TEXTURE_RECT_KEY];
    if(self = [super initWithFile:file rect:rect])
        [self initWithMaskTexture:nil size:CGSizeMake(rect.size.width * SIZE_FACTOR, rect.size.height * SIZE_FACTOR)]; //TODO
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.textureFileName forKey:TEXTURE_FILE_KEY];
    [aCoder encodeCGRect:rect_                forKey:TEXTURE_RECT_KEY];
}

- (id)initWithFile:(NSString *)file size:(CGSize)size
{
    self = [super initWithFile:file rect:CGRectMake(0, 0, size.width/SIZE_FACTOR, size.height/SIZE_FACTOR)];
    if (self) {
        self.textureFileName = file;
        
        //TODO: change pixelFormat to kCCTexture2DPixelFormat_RGB5A1
        CCRenderTexture *maskTexture = [CCRenderTexture renderTextureWithWidth:self.textureRect.size.width height:self.textureRect.size.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [maskTexture clear:INITIAL_RED g:0 b:0 a:1];
        [self initWithMaskTexture:maskTexture size:size];
    }
    return self;
}

- (void)initWithMaskTexture:(CCRenderTexture *)maskTexture size:(CGSize)size
{
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
    self.renderTexture = [CCRenderTexture renderTextureWithWidth:self.textureRect.size.width height:self.textureRect.size.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    [self.renderTexture clear:0 g:0 b:0 a:1];
    self.maskTexture = maskTexture;
    
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
    
    //Rescale back to greater size
    self.renderTexture.scale = 2;
    
    //On the lower left quarter of the screen.
    [self setPosition:ccp(size.width/4,size.height/4)];
    [self.maskTexture setPosition:ccp(size.width/4,size.height/4)];
    
    //On the center because scaled by 2 will fill the screen.
    [self.renderTexture setPosition:ccp(size.width/2,size.height/2)];
}

-(void) draw {
    
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
    [self.renderTexture visit];
    
}

- (void)addCircleAt:(CGPoint)center radius:(float)radius
{
    [self drawCircleAt:center radius:radius red:COVERED_RED];
}

- (void)removeCircleAt:(CGPoint)center radius:(float)radius
{
    [self drawCircleAt:center radius:radius red:INITIAL_RED];
}

- (void)drawCircleAt:(CGPoint)center radius:(float)radius red:(float)red
{

    ccColor4F color = ccc4f(red,0,0,1);
    [self.maskTexture begin];
    [self->pr drawDot:ccpMult(center,.5f) radius:(radius/2.f + .15f) color:color];
    [self->pr visit];
    [self->pr clear];
    [self.maskTexture end];
}

- (void)addPolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints
{
    [self drawPolygon:poly numPoints:numberOfPoints red:COVERED_RED];
}

- (void)removePolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints
{
    [self drawPolygon:poly numPoints:numberOfPoints red:INITIAL_RED];
}

- (void)drawPolygon:(CGPoint *)poly numPoints:(NSUInteger)numberOfPoints red:(float)red
{
    for(int i = 0; i < numberOfPoints; i++)
    {
        poly[i] = ccpMult(poly[i],.5f);
    }
    
    ccColor4F color = ccc4f(red,0,0,1);
    
    [self.maskTexture begin];
    [self->pr drawPolyWithVerts:poly count:numberOfPoints width:1 fill:color line:color];
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

- (void)clear
{
    [self.maskTexture clear:INITIAL_RED g:0 b:0 a:1];
    [self.renderTexture clear:0 g:0 b:0 a:0];

}

@end
