//
//  ScrollingBackground.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Background.h"
#import "cocos2d.h"

#define BACKGROUND_IMAGE_TAG 37475912 /* Kinda random integer to avoid conflicts */

@interface Background ()

/* Each index in the array points to an NSMutableArray of identical CGSprite's.
 * Each of those CGSprite's has the same x position and are tiled vertically.
 * Invariant: The images in backgrounds are in order of left to right
 */
@property (nonatomic, strong) NSMutableArray *backgrounds;

- (void)initBackgrounds;

@end

@implementation Background
@synthesize scrollSpeed = _scrollSpeed;
@synthesize backgrounds = _backgrounds;
@synthesize imageNames  = _imageNames;

- (void)initBackgrounds;
{
    [self setAnchorPoint:CGPointZero];
    
    if(self.children.count > 0)
        [self removeChildByTag:BACKGROUND_IMAGE_TAG cleanup:YES];
    NSArray *imageNames = self.imageNames;
    if(imageNames.count <= 0) {
        DebugLog(@"Warning: initBackgrounds was called and there weren't any images to use.");
        return;
    }
    if(self.boundingBox.size.width <= 0 || self.boundingBox.size.height <= 0) {
        DebugLog(@"Warning: initBackgrounds was called and the content size was 0");
        return;
    }
    self.backgrounds = [[NSMutableArray alloc] initWithCapacity:2];
    
    NSMutableArray *batchNodes = [[NSMutableArray alloc] initWithCapacity:imageNames.count];
    for(NSString *imageName in imageNames) {
        CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:imageName capacity:2];
        [self addChild:parent z:1 tag:BACKGROUND_IMAGE_TAG];
        [batchNodes addObject:parent];
    }
    CGFloat offset = 0;
    int imageIndex = 0;
    CGFloat maxWidth = 0;
    while(offset <= self.boundingBox.size.width + maxWidth || imageIndex != 0 || self.backgrounds.count < 2) {
        NSMutableArray *verticalTiling = [[NSMutableArray alloc]init];
        float backgroundHeight;
        for(float y=0; y < self.boundingBox.size.height; y += backgroundHeight) {
            CCSprite *background = [CCSprite spriteWithFile:[imageNames objectAtIndex:imageIndex]];
            backgroundHeight = background.boundingBox.size.height;
            background.anchorPoint = ccp(.5f,.5f);
            background.position = ccp(offset, y);
            [verticalTiling addObject:background];
            [[batchNodes objectAtIndex:imageIndex] addChild:background];
        }
        [self.backgrounds addObject:verticalTiling];
        
        float imageWidth = [(CCSprite *)verticalTiling.lastObject boundingBox].size.width;
        assert(imageWidth > 0);
        offset += imageWidth;
        if(imageWidth > maxWidth) maxWidth = imageWidth;
        imageIndex = (imageIndex + 1) % [imageNames count];
    }
}

- (id)initWithSpeed:(float)speed images:(NSArray *)imageNames
{
    if (self = [super init]) {
        [self setContentSize:CGSizeMake(self.contentSize.width*2, self.contentSize.height*2)];
        self.scrollSpeed = speed;
        self.imageNames = imageNames;
        [self scheduleUpdate];
    }
    return self;
}

- (void)setImageNames:(NSArray *)imageNames
{
    _imageNames = imageNames;
    [self initBackgrounds];
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    if(self.imageNames.count > 0)
        [self initBackgrounds];
}

- (void)update:(ccTime)dt
{
    if(self.scrollSpeed == 0) return;
    
    float deltaX = self.scrollSpeed * dt;
    int numBackgrounds = self.backgrounds.count;
    for(int i=0; i<numBackgrounds; i++) {
        NSMutableArray *backgroundTiled = [self.backgrounds objectAtIndex:i];
        CCSprite *background = [backgroundTiled lastObject];
        for(CCSprite *background in backgroundTiled)
            background.position = ccp(background.position.x - deltaX, background.position.y);
        if((self.scrollSpeed > 0 && background.position.x + background.boundingBox.size.width < 0) ||
           (self.scrollSpeed < 0 && background.position.x > self.boundingBox.size.width)) {
            CGFloat newX = 0;
            if(self.scrollSpeed > 0) {
                int index = i-1;
                if(index < 0) {
                    index += numBackgrounds;
                    newX = -deltaX;
                }
                CCSprite *leftBackground = [(NSMutableArray *)[self.backgrounds objectAtIndex:index] lastObject];
                assert(leftBackground);
                newX += leftBackground.position.x + leftBackground.boundingBox.size.width;
            } else {
                int index = i+1;
                if(index >= numBackgrounds) {
                    index -= numBackgrounds;
                    newX = deltaX;
                }
                CCSprite *rightBackground = [(NSMutableArray *)[self.backgrounds objectAtIndex:index] lastObject];
                assert(rightBackground);
                newX += -deltaX + rightBackground.position.x - background.boundingBox.size.width;
            }
            for(CCSprite *background in backgroundTiled) {
                background.position = ccp(newX, background.position.y);
            }
        }
    }
}

//Camera object

-(float)getParallaxRatio{
    return .3f;
}

-(bool)isBounded{
    return NO;
}
@end
