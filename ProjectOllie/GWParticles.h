//
//  GWParticles.h
//  ProjectOllie
//
//  Created by Lion User on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ccMacros.h"
#import "CCParticleSystemQuad.h"

// build each architecture with the optimal particle system

// ARMv7, Mac or Simulator use "Quad" particle
#if defined(__ARM_NEON__) || defined(__CC_PLATFORM_MAC) || TARGET_IPHONE_SIMULATOR
#define ARCH_OPTIMAL_PARTICLE_SYSTEM CCParticleSystemQuad

// ARMv6 use "Point" particle
#elif __arm__
#define ARCH_OPTIMAL_PARTICLE_SYSTEM CCParticleSystemPoint
#else
#error(unknown architecture)
#endif


// A rain particle system
@interface GWParticleRain: ARCH_OPTIMAL_PARTICLE_SYSTEM
{
}
@end

// A magic missile particle system
@interface GWParticleMagicMissile: ARCH_OPTIMAL_PARTICLE_SYSTEM
{
}
@end

// An exploding ring particle system
@interface GWParticleExplodingRing: ARCH_OPTIMAL_PARTICLE_SYSTEM
{
}
@end

// An blue ring particle system
@interface GWParticleBlueFountain: ARCH_OPTIMAL_PARTICLE_SYSTEM
{
}
@end

// An blue ring particle system
@interface GWParticleMuzzleFlash: ARCH_OPTIMAL_PARTICLE_SYSTEM
{
}
@end