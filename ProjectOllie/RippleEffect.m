//
//  RippleEffect.m
//  ProjectOllie
//
//  Created by Lion User on 6/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RippleEffect.h"
#import "cocos2d.h"
#import "RippleSprite.h"

@interface RippleEffect ()

@property (nonatomic, strong) CCRenderTexture *renderTexture;
@property (nonatomic, strong) CCNode *renderParent;

-(void)updateRenderTexture;

@end

@implementation RippleEffect{
    
    RippleSprite* ripplesprite;
    
}

@synthesize renderTexture = _renderTexture;
@synthesize renderParent  = _renderParent;

-(id)initWithParent:(CCNode *)parent
{
    if((self = [self init]))
    {
        self.renderParent = parent;
        [self updateRenderTexture];
        [self scheduleUpdate];
        
        ripplesprite = [RippleSprite spriteWithTexture:self.renderTexture.sprite.texture];
        [self.renderParent addChild:ripplesprite];
    }
    return self;
}

+(id)nodeWithParent:(CCNode *)parent
{
    return [[RippleEffect alloc] initWithParent:parent];
}
- (id)init
{
    self = [super init];
    if (self) {
        CGSize s = [[CCDirector sharedDirector] winSize];

        self.renderTexture = [CCRenderTexture renderTextureWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        self.renderTexture.position = CGPointMake(s.width, s.height);
        [self.renderTexture clear:0 g:0 b:0 a:0];
        glClearColor(0, 0, 0, 0);
        
    }
    return self;
}


-(void)updateRenderTexture
{
    [self.renderTexture clear:0 g:0 b:0 a:0];
    [self.renderTexture begin];
    [self.renderParent visit];
    [self.renderTexture end];
    ripplesprite.texture = self.renderTexture.sprite.texture;

}


@end