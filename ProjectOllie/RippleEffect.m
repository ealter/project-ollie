//
//  RippleEffect.m
//  ProjectOllie
//
//  Created by Lion User on 6/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RippleEffect.h"


@implementation RippleEffect{
    CCSprite *sprite;  //1
    int timeUniformLocation;
    float totalTime;
}

- (id)init
{
    self = [super init];
    if (self) {
        // 1
		sprite = [CCSprite spriteWithFile:@"white_clouds.jpeg"];
		sprite.anchorPoint = CGPointMake(0.5, 0.5);
		sprite.position = CGPointMake([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2);
		[self addChild:sprite];
        
        // 2
        NSError *error = nil;
        GLchar *mask_frag = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RippleEffect" ofType:@"fsh"] encoding:NSUTF8StringEncoding error:&error] UTF8String];
        if(error) {
            DebugLog(@"The error: %@", error);
        }
        assert(mask_frag);
        sprite.shaderProgram = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert
                                                          fragmentShaderByteArray:mask_frag];
        [sprite.shaderProgram addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [sprite.shaderProgram addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        [sprite.shaderProgram link];
        [sprite.shaderProgram updateUniforms];
        
        // 3
		timeUniformLocation = glGetUniformLocation(sprite.shaderProgram->program_, "u_time");
        
		// 4
		[self scheduleUpdate];
        
        // 5
        [sprite.shaderProgram use];
        
    }
    return self;
}

- (void)update:(float)dt
{
    totalTime += dt;
    [sprite.shaderProgram use];
    glUniform1f(timeUniformLocation, totalTime);
}

@end
