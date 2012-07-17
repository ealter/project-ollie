//
//  RippleSprite.m
//  ProjectOllie
//
//  Created by Lion User on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RippleEffect.h"
#import "cocos2d.h"

@interface RippleEffect()

/* Shader locations for the values we give it */
@property (nonatomic, assign) GLuint invDistanceLoc;
@property (nonatomic, assign) GLuint speedLoc;
@property (nonatomic, assign) GLuint lifetimeLoc;
@property (nonatomic, assign) GLuint timeUniformLoc;
@property (nonatomic, assign) GLuint originXUniformLoc;
@property (nonatomic, assign) GLuint originYUniformLoc;

/* The node that is being rippled */
@property (nonatomic, strong) CCNode *target;

/* The speed at which ripples propogate */
@property (nonatomic, assign) float rippleSpeed;

/* The inverse distance between ripples */
@property (nonatomic, assign) float invDistanceValue;

/* The renderTexture of the screen that we use */
@property (nonatomic, strong) CCRenderTexture *renderTexture;

@property (nonatomic, strong) CCRenderTexture *scaledTexture;

/* The total time elapsed since updating hath begun */
@property (assign, nonatomic) float totalTime;

/* The origin of the ripple */
@property (assign, nonatomic) CGPoint origin;

@end

@implementation RippleEffect

@synthesize invDistanceLoc      = _invDistanceLoc;
@synthesize speedLoc            = _speedLoc;
@synthesize lifetimeLoc         = _lifetimeLoc;
@synthesize timeUniformLoc      = _timeUniformLoc;
@synthesize originXUniformLoc   = _originXUniformLoc;
@synthesize originYUniformLoc   = _originYUniformLoc;
@synthesize target              = _target;
@synthesize rippleSpeed         = _rippleSpeed;
@synthesize invDistanceValue    = _invDistanceValue;
@synthesize lifetime            = _lifetime;
@synthesize totalTime           = _totalTime;
@synthesize renderTexture       = _renderTexture;
@synthesize scaledTexture       = _scaledTexture;
@synthesize origin              = _origin;

-(id)initWithSubject:(CCNode*)subject atOrigin:(CGPoint)origin{
    
    /* Set up rendertexture */
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    rt.position = CGPointMake(s.width/4, s.height/4);
    
    [rt clear:0 g:0 b:0 a:0];
    
    //call init using rendertexture's texture
    if(self = [super initWithTexture:rt.sprite.texture]) {
        self.rippleSpeed      = 20.0;
        self.invDistanceValue = 18.0;
        self.lifetime         = .5f;
        self.totalTime        = 0.f;
        self.target           = subject;
        self.renderTexture    = rt;
        self.origin           = ccp(-origin.x/s.width, -origin.y/s.height);
        
        self.scaledTexture = [CCRenderTexture renderTextureWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        
        
        NSError *error = nil;
        GLchar *ripple_frag = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RippleEffect" ofType:@"fsh"] encoding:NSUTF8StringEncoding error:&error] UTF8String];
        if(error) {
            DebugLog(@"The error: %@", error);
        }
        assert(ripple_frag);

        self.shaderProgram = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert fragmentShaderByteArray:ripple_frag];
        [self.shaderProgram addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [self.shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        [self.shaderProgram link];
        [self.shaderProgram updateUniforms];
        
        self.timeUniformLoc     = glGetUniformLocation(self.shaderProgram->program_, "u_time");
        self.invDistanceLoc     = glGetUniformLocation(self.shaderProgram->program_, "invdistance");
        self.speedLoc           = glGetUniformLocation(self.shaderProgram->program_, "speed");
        self.lifetimeLoc        = glGetUniformLocation(self.shaderProgram->program_, "lifetime");
        self.originXUniformLoc  = glGetUniformLocation(self.shaderProgram->program_, "originX");
        self.originYUniformLoc  = glGetUniformLocation(self.shaderProgram->program_, "originY");        
        
        [self setBlendFunc: (ccBlendFunc) {GL_ONE, GL_ZERO}];
        [self.shaderProgram use];
        
        //set shader values 
        glUniform1f(self.speedLoc, self.rippleSpeed);
        glUniform1f(self.invDistanceLoc, self.invDistanceValue);
        glUniform1f(self.lifetimeLoc, self.lifetime);
        glUniform1f(self.originXUniformLoc, self.origin.x);
        glUniform1f(self.originYUniformLoc, self.origin.y);
        
        //sprite properties
        [self scheduleUpdate];
        self.flipY = YES;
        
        [self setPosition:ccp(self.contentSize.width/4.f,self.contentSize.height/4.f)];
    }
    return self;
}

-(void)update:(float)dt{
    if(self.totalTime < self.lifetime) {
        [self.renderTexture beginWithClear:0 g:0 b:0 a:0];
        [self.target visit];
        [self.renderTexture end];
        self.texture = self.renderTexture.sprite.texture;
    }
    else {
        [self.parent removeChild:self cleanup:YES];
    }
    
    self.totalTime += dt;
    [self.shaderProgram use];
    glUniform1f(self.timeUniformLoc, self.totalTime);
}

-(void)setLifetime:(float)lifetime{
    self->_lifetime = lifetime;
    glUniform1f(self.lifetimeLoc, self.lifetime);
}

@end
