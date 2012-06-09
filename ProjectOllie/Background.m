//
//  ScrollingBackground.m
//  ProjectOllie
//
//  Created by Lion User on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Background.h"


@interface Background ()

/* An array of CGSprite *'s with the same image
   Invariant: The images are in order of left to right
 */
@property (nonatomic, retain) NSMutableArray *backgrounds;

- (void)initBackgroundsWithNames:(NSArray *)imageNames;
- (CCSprite *)initBackground:(NSString *)imageName atOffset:(CGFloat)offset;

@end

@implementation Background
@synthesize scrollSpeed = _scrollSpeed;
@synthesize backgrounds = _backgrounds;

- (void)initBackgroundsWithNames:(NSArray *)imageNames
{
    self.backgrounds = [[NSMutableArray alloc]initWithCapacity:2];
    
    CGFloat offset = 0;
    int imageIndex = 0;
    CGFloat maxWidth = 0;
    while(offset <= self.boundingBox.size.width + maxWidth || imageIndex != 0) {
        CCSprite *background = [self initBackground:[imageNames objectAtIndex:imageIndex] atOffset:offset];
        float imageWidth = background.boundingBox.size.width;
        offset += imageWidth;
        if(imageWidth > maxWidth) maxWidth = imageWidth;
        imageIndex = (imageIndex + 1) % [imageNames count];
    }
}

- (CCSprite *)initBackground:(NSString *)imageName atOffset:(CGFloat)offset
{
    CCSprite *background = [CCSprite spriteWithFile:imageName];
    background.anchorPoint = ccp(0,0);
    background.position = ccp(offset, 0);
    [self.backgrounds addObject:background];
    [self addChild:background];
    return background;
}

- (id)initWithSpeed:(int)speed images:(NSArray *)imageNames
{
    if (self = [super init]) {
        self.scrollSpeed = speed;
        
        [self initBackgroundsWithNames:imageNames];
        //add schedule to move backgrounds
        // [self schedule:@selector(scroll:) interval:0.005];
    }
    return self;
}


- (void) scroll:(ccTime)dt{

    int numBackgrounds = self.backgrounds.count;
    for(int i=0; i<numBackgrounds; i++) {
        CCSprite *background = [self.backgrounds objectAtIndex:i];
        background.position = ccp(background.position.x - self.scrollSpeed, background.position.y);
        if(background.position.x + background.boundingBox.size.width < 0) {
            int index = i-1;
            if(index < 0) index += numBackgrounds;
            CCSprite *leftBackground  = [self.backgrounds objectAtIndex:index];
            background.position = ccp(leftBackground.position.x + leftBackground.boundingBox.size.width, background.position.y);
        }
    }

}

@end
