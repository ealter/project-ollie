//
//  ScrollingBackground.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Background.h"

@interface Background ()

/* Each index in the array points to an NSMutableArray of identical CGSprite's.
 * Each of those CGSprite's has the same x position and are tiled vertically.
 * Invariant: The images in backgrounds are in order of left to right
 */
@property (nonatomic, retain) NSMutableArray *backgrounds;

- (void)initBackgroundsWithNames:(NSArray *)imageNames;

@end

@implementation Background
@synthesize scrollSpeed = _scrollSpeed;
@synthesize backgrounds = _backgrounds;

- (void)initBackgroundsWithNames:(NSArray *)imageNames
{
    self.backgrounds = [[NSMutableArray alloc]initWithCapacity:2];
    
    NSMutableArray *batchNodes = [[NSMutableArray alloc]initWithCapacity:imageNames.count];
    for(NSString *imageName in imageNames) {
        CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:imageName capacity:2];
        [self addChild:parent];
        [batchNodes addObject:parent];
    }
    CGFloat offset = 0;
    int imageIndex = 0;
    CGFloat maxWidth = 0;
    while(offset <= self.boundingBox.size.width + maxWidth || imageIndex != 0) {
        NSMutableArray *verticalTiling = [[NSMutableArray alloc]init];
        float backgroundHeight;
        for(float y=0; y < self.boundingBox.size.height; y += backgroundHeight) {
            CCSprite *background = [CCSprite spriteWithFile:[imageNames objectAtIndex:imageIndex]];
            backgroundHeight = background.boundingBox.size.height;
            background.anchorPoint = ccp(0,0);
            background.position = ccp(offset, y);
            [verticalTiling addObject:background];
            [[batchNodes objectAtIndex:imageIndex] addChild:background];
        }
        [self.backgrounds addObject:verticalTiling];
        
        float imageWidth = [(CCSprite *)verticalTiling.lastObject boundingBox].size.width;
        offset += imageWidth;
        if(imageWidth > maxWidth) maxWidth = imageWidth;
        imageIndex = (imageIndex + 1) % [imageNames count];
    }
}

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    [scene addChild: [self node]];
    return scene;
}

- (id)initWithSpeed:(int)speed images:(NSArray *)imageNames
{
    if (self = [super init]) {
        self.scrollSpeed = speed;
        
        [self initBackgroundsWithNames:imageNames];
        //add schedule to move backgrounds
        [self schedule:@selector(scroll:) interval:0.005];
    }
    return self;
}

- (void) scroll:(ccTime)dt{
    int numBackgrounds = self.backgrounds.count;
    for(int i=0; i<numBackgrounds; i++) {
        NSMutableArray *backgroundTiled = [self.backgrounds objectAtIndex:i];
        CCSprite *background = [backgroundTiled lastObject];
        for(CCSprite *background in backgroundTiled)
            background.position = ccp(background.position.x - self.scrollSpeed, background.position.y);
        if(background.position.x + background.boundingBox.size.width < 0) {
            int index = i-1;
            if(index < 0) index += numBackgrounds;
            CCSprite *leftBackground  = [(NSMutableArray *)[self.backgrounds objectAtIndex:index] lastObject];
            background = nil;
            for(CCSprite *background in backgroundTiled) {
                background.position = ccp(leftBackground.position.x + leftBackground.boundingBox.size.width, background.position.y);
            }
        }
    }
}

@end
