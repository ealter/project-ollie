//
//  RippleSprite.m
//  ProjectOllie
//
//  Created by Lion User on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RippleSprite.h"
#import "cocos2d.h"

@interface RippleSprite()

@property (nonatomic) GLuint invdistance;
@property (nonatomic) GLuint speed;
@property (nonatomic, retain) CCNode *target;
@property (nonatomic) float rippleSpeed;
@property (nonatomic) float invDistanceValue;

@end

@implementation RippleSprite{

    int timeUniformLocation;
    float totalTime;
}
@synthesize invdistance      = _invdistance;
@synthesize speed            = _speed;
@synthesize target           = _target;
@synthesize rippleSpeed      = _rippleSpeed;
@synthesize invDistanceValue = _invDistanceValue;

-(id)initWithTexture:(CCTexture2D *)texture{
    
    if(self = [super initWithTexture:texture])
    {
        self.rippleSpeed = 10.;
        self.invDistanceValue = 20;
        totalTime = 0;
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
        
        timeUniformLocation = glGetUniformLocation(self.shaderProgram->program_, "u_time");
        self.invdistance  = glGetUniformLocation(self.shaderProgram->program_, "invdistance");
        self.speed  = glGetUniformLocation(self.shaderProgram->program_, "speed");
        
        [self.shaderProgram use];
        [self scheduleUpdate];
        self.flipY = YES;
        [self setPosition:ccp(self.contentSize.width/2.f,self.contentSize.height/2.f)];
    }
    return self;
}

-(void)update:(float)dt{

    totalTime += dt;
    if (totalTime > 2000) {
        totalTime = 0;
    }
    [self.shaderProgram use];
    glClearColor(0, 0, 0, 0);
    glUniform1f(timeUniformLocation, totalTime);
    glUniform1f(self.speed, self.rippleSpeed);
    glUniform1f(self.invdistance, self.invDistanceValue);
    
}

@end
