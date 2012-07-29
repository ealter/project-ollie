//
//  GWParticles.m
//  ProjectOllie
//
//  Created by Lion User on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GWParticles.h"
#import "CCTextureCache.h"
#import "CCDirector.h"
#import "CGPointExtension.h"

const static ccColor4F kColor4fZero = {0,0,0,0};

@implementation GWParticleRain
-(id) init
{
    return [self initWithTotalParticles:300];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = kCCParticleDurationInfinity;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Gravity Mode: gravity
        self.gravity = CGPointMake(0,-120);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 86;
        self.speedVar = 0;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position  = ccp(winSize.width/2, winSize.height);
        self.posVar    = ccp(winSize.width/2, 0);
        // angle
        angle = 90;
        angleVar = 12;
        
        // life of particles
        life = 7.8f;
        lifeVar = 1;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0.7, 0.78, 1.0,  0.86);
        startColorVar = ccc4f(0.0, 0.0,  0.51, 0.0);
        endColor      = ccc4f(0.0, 0.44, 1.0,  0.0);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 6.0f;
        startSizeVar = 3.0f;
        endSize = kCCParticleStartSizeEqualToEndSize;
        
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = NO;
    }
    
    return self;
}
@end


@implementation GWParticleMagicMissile
-(id) init
{
    return [self initWithTotalParticles:300];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = kCCParticleDurationInfinity;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Gravity Mode: gravity
        self.gravity = CGPointZero;
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 50;
        self.speedVar = 0;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        // angle
        angle = 180;
        angleVar = 0;
        
        // life of particles
        life = 2.f;
        lifeVar = 0;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0.0, 0.05, 1.0, 1.0);
        startColorVar = kColor4fZero;
        endColor      = ccc4f(0.0, 0.05, 1.0, 1.0);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 20.0f;
        startSizeVar = 0.0f;
        endSize = 1.f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];        
        
        //Get the particle texture
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = YES;
    }
    
    return self;
}
@end

@implementation GWParticleExplodingRing
-(id) init
{
    return [self initWithTotalParticles:250];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = 0.01;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Gravity Mode: gravity
        self.gravity = ccp(1.15, 1.58);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 150;
        self.speedVar = 1;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        
        // angle
        angle = 360;
        angleVar = 360;
        
        // life of particles
        life = 0.f;
        lifeVar = 1.118f;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0.89, 0.56, 0.36, 1.0);
        startColorVar = ccc4f(0.2,  0.2,  0.2,  0.5);
        endColor      = ccc4f(0.0,  0.0,  0.0,  0.84);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 34.0f;
        startSizeVar = 30.0f;
        endSize = 14.f;
        endSizeVar = 0.0f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];        
        
        //Get the particle texture0
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = YES;
    }
    
    return self;
}
@end

@implementation GWParticleBlueFountain
-(id) init
{
    return [self initWithTotalParticles:350];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = kCCParticleDurationInfinity;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Gravity Mode: gravity
        self.gravity = ccp(0,-750);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 100;
        self.speedVar = 0;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        
        // angle
        angle = 0;
        angleVar = 360;
        
        // life of particles
        life = 0.46f;
        lifeVar = 0.59f;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0.0,  0.49, 0.66, 1.0);
        startColorVar = ccc4f(0.59, 0.0,  0.0,  0.0);
        endColor      = ccc4f(0.14, 0.26, 0.39, 1.0);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 0.0f;
        startSizeVar = 19.0f;
        endSize = 28.f;
        endSizeVar = 0.0f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];        
        
        //Get the particle texture0
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = YES;
    }
    
    return self;
}
@end

//TODO: add variables that easily control the angle
@implementation GWParticleMuzzleFlash
-(id) init
{
    return [self initWithTotalParticles:50];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = 0.2;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Gravity Mode: gravity
        //This is where you would change the angle of the muzzle flash
        self.gravity = ccp(1000,0);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 0;
        self.speedVar = 0;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = ccp(7, 4);
        
        // angle
        angle = 90;
        angleVar = 0;
        
        // life of particles
        life = 0.2f;
        lifeVar = 0.0f;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0.52, 0.35, 0.0, 0.35);
        startColorVar = kColor4fZero;
        endColor      = ccc4f(1.0,  0.0,  0.0, 0.73);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 20.0f;
        startSizeVar = 0.0f;
        endSize = 12.f;
        endSizeVar = 0.0f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_ONE, GL_ONE }];        
        
        //Get the particle texture0
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = YES;
    }
    
    return self;
}
@end
