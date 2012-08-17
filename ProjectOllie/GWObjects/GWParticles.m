//
//  GWParticles.m
//  ProjectOllie
//
//  Created by Lion User on 6/30/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
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
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
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
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        self.gravity = CGPointZero;
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 0;
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
        
        //position type
        self.positionType = kCCPositionTypeRelative;
        
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
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
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
    return [self initWithTotalParticles:200];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = 0.02;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        //This is where you would change the angle of the muzzle flash
        self.gravity = ccp(0,0);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 0;
        self.speedVar = 0;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = ccp(4, 4);
        
        // angle
        angle = 0;
        angleVar = 0;
        
        // life of particles
        life = 0.0f;
        lifeVar = 0.2f;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(1., 0.77, 0.32, 0.35);
        startColorVar = ccc4f(1., 0., 0., 0.3);
        endColor      = ccc4f(1.0,  0.0,  0.0, 1.);
        endColorVar   = ccc4f(1., 0., 0., 0.);
        
        // size, in pixels
        startSize = 10.0f;
        startSizeVar = 0.0f;
        endSize = 1.f;
        endSizeVar = 0.0f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_DST_ALPHA, GL_ONE }];        
        
        //Get the particle texture0
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = YES;
    }
    
    return self;
}
@end

@implementation GWParticleExplosion
-(id) init
{
    return [self initWithTotalParticles:300];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = 0.01;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        self.gravity = ccp(0, -500);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 0;
        self.speedVar = 500;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        
        // angle
        angle = 0;
        angleVar = 360;
        
        // life of particles
        life = 0.f;
        lifeVar = 2.;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(1., 0.0, 0., 1.);
        startColorVar = ccc4f(1., .22, 0., 0.5);
        endColor      = ccc4f(0.,  0.,  0.0,  0.31);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 40.0f;
        startSizeVar = 12.0f;
        endSize = 2.f;
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

@implementation GWParticleSoundCircle
-(id) init
{
    return [self initWithTotalParticles:500];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = -1.00;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        self.gravity = ccp(0, 0);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 400;
        self.speedVar = 0;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        
        // angle
        angle = 0;
        angleVar = 360;
        
        // life of particles
        life = 0.3f;
        lifeVar = 0;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(1., 1., 1., 1.);
        startColorVar = ccc4f(0., 0., 0., 0.);
        endColor      = ccc4f(1., 1., 1., 1.);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 10.0f;
        startSizeVar = 0.f;
        endSize = 6.f;
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

@implementation GWParticleExplosion2
-(id) init
{
    return [self initWithTotalParticles:500];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = 0.01;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        self.gravity = ccp(0, 0);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 112;
        self.speedVar = 700;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        
        // angle
        angle = 0;
        angleVar = 360;
        
        // life of particles
        life = 0.f;
        lifeVar = .58;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(1., .5, 0., 1.);
        startColorVar = ccc4f(.2, 0., 0., .2);
        endColor      = ccc4f(1., 0., 0., 0.);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 25.0f;
        startSizeVar = 3.0f;
        endSize = 0.f;
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

@implementation GWParticleBloom
-(id) init
{
    return [self initWithTotalParticles:500];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = -1.0;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        self.gravity = ccp(0, 0);
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 0;
        self.speedVar = 75;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        
        // angle
        angle = 0;
        angleVar = 360;
        
        // life of particles
        life = 0.f;
        lifeVar = 2.;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0., .5, 1., 1.);
        startColorVar = ccc4f(0., 0., 0., 0.);
        endColor      = ccc4f(0., 0., 1., 1.);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 20.0f;
        startSizeVar = 27.0f;
        endSize = 0.f;
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

@implementation GWParticleSmokeTrail
-(id) init
{
    return [self initWithTotalParticles:500];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = kCCParticleDurationInfinity;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        self.gravity = CGPointZero;
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //  Gravity Mode: speed of particles
        self.speed = 0;
        self.speedVar = 0;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        // angle
        angle = 0;
        angleVar = 10;
        
        // life of particles
        life = 4.5f;
        lifeVar = 0;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0.1, 0.09, 0.07, 1.0);
        startColorVar = ccc4f(0., 0., 0., 0.5);
        endColor      = ccc4f(0.3, 0.27, 0.21, 0.01);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 36.0f;
        startSizeVar = 0.0f;
        endSize = 36.f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA }];        
        
        //Get the particle texture
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = YES;
    }
    
    return self;
}
@end

@implementation GWParticleSpookyPurple
-(id) init
{
    return [self initWithTotalParticles:250];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        // duration
        duration = kCCParticleDurationInfinity;
        
        // Gravity Mode
        self.emitterMode = kCCParticleModeGravity;
        
        // Position Type
        self.positionType = kCCPositionTypeRelative;
        
        // Gravity Mode: gravity
        self.gravity = CGPointZero;
        
        // Gravity Mode:  radial
        self.radialAccel = 0;
        self.radialAccelVar = 0;
        
        //Tangential stuff
        self.tangentialAccelVar = 150;
        
        //  Gravity Mode: speed of particles
        self.speed = 0;
        self.speedVar = 20;
        
        // emitter position
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.position = ccpMult(ccpFromSize(winSize), 0.5);
        self.posVar = CGPointZero;
        // angle
        angle = 90;
        angleVar = 10;
        
        // life of particles
        life = 2.f;
        lifeVar = 0;
        
        // emits per frame
        emissionRate = totalParticles/life;
        
        // color of particles
        startColor    = ccc4f(0.8, 0.14, 0.67, 1.0);
        startColorVar = ccc4f(0., 0., 0., 0.);
        endColor      = ccc4f(0., 0., 0., 1.);
        endColorVar   = kColor4fZero;
        
        // size, in pixels
        startSize = 64.0f;
        startSizeVar = 5.0f;
        endSize = 0.f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_ZERO, GL_ZERO }];        
        
        //Get the particle texture
        self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
        // additive
        self.blendAdditive = YES;
    }
    
    return self;
}
@end
