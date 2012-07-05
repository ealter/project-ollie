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
		self.position = CGPointMake(winSize.width/2, winSize.height);
        self.posVar = CGPointMake(winSize.width/2, 0);
		// angle
		angle = 90;
		angleVar = 12;
        
		// life of particles
		life = 7.8f;
		lifeVar = 1;
        
		// emits per frame
		emissionRate = totalParticles/life;
        
		// color of particles
		startColor.r    = 0.7f;
		startColor.g    = 0.78f;
		startColor.b    = 1.0f;
		startColor.a    = 0.86f;
        
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.51f;
		startColorVar.a = 0.0f;
        
		endColor.r      = 0.0f;
		endColor.g      = 0.44f;
		endColor.b      = 1.0f;
		endColor.a      = 0.0f;
        
		endColorVar.r   = 0.0f;
		endColorVar.g   = 0.0f;
		endColorVar.b   = 0.0f;
		endColorVar.a   = 0.0f;
        
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
		self.gravity = CGPointMake(0,0);
        
		// Gravity Mode:  radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
        
		//  Gravity Mode: speed of particles
		self.speed = 50;
		self.speedVar = 0;
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = CGPointMake(winSize.width/2, winSize.height/2);
        self.posVar = CGPointMake(0, 0);
		// angle
		angle = 180;
		angleVar = 0;
        
		// life of particles
		life = 2.f;
		lifeVar = 0;
        
		// emits per frame
		emissionRate = totalParticles/life;
        
		// color of particles
		startColor.r    = 0.0f;
		startColor.g    = 0.05f;
		startColor.b    = 1.0f;
		startColor.a    = 1.0f;
        
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
        
		endColor.r      = 0.0f;
		endColor.g      = 0.05f;
		endColor.b      = 1.0f;
		endColor.a      = 1.0f;
        
		endColorVar.r   = 0.0f;
		endColorVar.g   = 0.0f;
		endColorVar.b   = 0.0f;
		endColorVar.a   = 0.0f;
        
		// size, in pixels
		startSize = 20.0f;
		startSizeVar = 0.0f;
		endSize = 1.f;
        
        //Change the GL blend function
        [self setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
        //ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE);
        
        
        //Get the particle texture0
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
		self.gravity = CGPointMake(1.15,1.58);
        
		// Gravity Mode:  radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
        
		//  Gravity Mode: speed of particles
		self.speed = 150;
		self.speedVar = 1;
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = CGPointMake(winSize.width/2, winSize.height/2);
        self.posVar = CGPointMake(0, 0);
        
		// angle
		angle = 360;
		angleVar = 360;
        
		// life of particles
		life = 0.f;
		lifeVar = 1.118f;
        
		// emits per frame
		emissionRate = totalParticles/life;
        
		// color of particles
		startColor.r    = 0.89f;
		startColor.g    = 0.56f;
		startColor.b    = 0.36f;
		startColor.a    = 1.0f;
        
		startColorVar.r = 0.2f;
		startColorVar.g = 0.2f;
		startColorVar.b = 0.2f;
		startColorVar.a = 0.5f;
        
		endColor.r      = 0.0f;
		endColor.g      = 0.0f;
		endColor.b      = 0.0f;
		endColor.a      = 0.84f;
        
		endColorVar.r   = 0.0f;
		endColorVar.g   = 0.0f;
		endColorVar.b   = 0.0f;
		endColorVar.a   = 0.0f;
        
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
		self.gravity = CGPointMake(0,-750);
        
		// Gravity Mode:  radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
        
		//  Gravity Mode: speed of particles
		self.speed = 100;
		self.speedVar = 0;
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = CGPointMake(winSize.width/2, winSize.height/2);
        self.posVar = CGPointMake(0, 0);
        
		// angle
		angle = 0;
		angleVar = 360;
        
		// life of particles
		life = 0.46f;
		lifeVar = 0.59f;
        
		// emits per frame
		emissionRate = totalParticles/life;
        
		// color of particles
		startColor.r    = 0.0f;
		startColor.g    = 0.49f;
		startColor.b    = 0.66f;
		startColor.a    = 1.0f;
        
		startColorVar.r = 0.59f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
        
		endColor.r      = 0.14f;
		endColor.g      = 0.26f;
		endColor.b      = 0.39f;
		endColor.a      = 1.0f;
        
		endColorVar.r   = 0.0f;
		endColorVar.g   = 0.0f;
		endColorVar.b   = 0.0f;
		endColorVar.a   = 0.0f;
        
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
		self.gravity = CGPointMake(1000,0);
        
		// Gravity Mode:  radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
        
		//  Gravity Mode: speed of particles
		self.speed = 0;
		self.speedVar = 0;
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = CGPointMake(winSize.width/2, winSize.height/2);
        self.posVar = CGPointMake(7, 4);
        
		// angle
		angle = 90;
		angleVar = 0;
        
		// life of particles
		life = 0.2f;
		lifeVar = 0.0f;
        
		// emits per frame
		emissionRate = totalParticles/life;
        
		// color of particles
		startColor.r    = 0.52f;
		startColor.g    = 0.35f;
		startColor.b    = 0.0f;
		startColor.a    = 0.35f;
        
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
        
		endColor.r      = 1.0f;
		endColor.g      = 0.0f;
		endColor.b      = 0.0f;
		endColor.a      = 0.73f;
        
		endColorVar.r   = 0.0f;
		endColorVar.g   = 0.0f;
		endColorVar.b   = 0.0f;
		endColorVar.a   = 0.0f;
        
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
