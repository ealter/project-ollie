//
//  RippleEffect.m
//  ProjectOllie
//
//  Created by Lion User on 6/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RippleEffect.h"
#import "cocos2d.h"
#import "CCGLProgram.h"
#import "HMVectorNode.h"

@interface RippleEffect ()

@property  (nonatomic) GLuint invdistance;
@property  (nonatomic) GLuint speed;
@property (nonatomic, retain) CCNode *target;
@property (nonatomic) float rippleSpeed;
@property (nonatomic) float invDistanceValue;

@end

@implementation RippleEffect{
    CCSprite *sprite;  //1
    int timeUniformLocation;
    float totalTime;
}
@synthesize invdistance = invdistance_, speed = speed_, target, rippleSpeed, invDistanceValue;

-(id)initWithTarget:(CCNode *)targetNode
{
    self.target = targetNode;
    return [self init];
}

+(id)nodeWithTarget:(CCNode *)target{
    return  [[[self alloc] initWithTarget:target] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        rippleSpeed = 2.;
        invDistanceValue = 10;        
        // 2
        NSError *error = nil;
        GLchar *mask_frag = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RippleEffect" ofType:@"fsh"] encoding:NSUTF8StringEncoding error:&error] UTF8String];
        if(error) {
            DebugLog(@"The error: %@", error);
        }
        assert(mask_frag);
        self.target.shaderProgram = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert fragmentShaderByteArray:mask_frag];
        [self.target.shaderProgram addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [self.target.shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        [self.target.shaderProgram link];
        [self.target.shaderProgram updateUniforms];
        
        // 3
		timeUniformLocation = glGetUniformLocation(self.target.shaderProgram->program_, "u_time");
        
		// 4
		[self scheduleUpdate];
        
        self.invdistance  = glGetUniformLocation(self.target.shaderProgram->program_, "invdistance");
        self.speed  = glGetUniformLocation(self.target.shaderProgram->program_, "speed");
        
        // 5
        [self.target.shaderProgram use];
        
    }
    return self;
}

- (void)update:(float)dt
{
    totalTime += dt;
    [self.target.shaderProgram use];
    glUniform1f(timeUniformLocation, totalTime);
    glUniform1f(self.speed, rippleSpeed);
    glUniform1f(self.invdistance, invDistanceValue);
}

@end
