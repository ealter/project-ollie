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

- (void)initBackgrounds;
- (void)initBackground:(CCSprite *)background atOffset:(CGFloat)offset;

@end

@implementation Background
@synthesize scrollSpeed = _scrollSpeed;
@synthesize imageName = _imageName;
@synthesize backgrounds = _backgrounds;

- (void)initBackgrounds {
    //create both sprite to handle background
    self.backgrounds = [[NSMutableArray alloc]initWithCapacity:2];
    
    CGFloat offset = 0;
    while(offset < self.boundingBox.size.width) {
        CCSprite *background = [CCSprite spriteWithFile:self.imageName];
        [self initBackground:background atOffset:offset];
        offset += background.boundingBox.size.width;
    }
    //Repeat so that we have overflow
    CCSprite *background = [CCSprite spriteWithFile:self.imageName];
    [self initBackground:background atOffset:offset];
    offset += background.boundingBox.size.width;
}

- (void)initBackground:(CCSprite *)background atOffset:(CGFloat)offset
{
    background.anchorPoint = ccp(0,0);
    background.position = ccp(offset, 0);
    [self.backgrounds addObject:background];
    [self addChild:background];
}

- (NSMutableArray *)backgrounds {
    if(!_backgrounds) {
        [self initBackgrounds];
    }
    return _backgrounds;
}

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    Background *layer = [Background node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

-(id)initwithSpeed:(int) speed andImage: (NSString *) imageName
{
    if (self = [super init]) {
        self.scrollSpeed = speed;
        self.imageName = imageName;
        
        [self initBackgrounds];
        //add schedule to move backgrounds
        [self schedule:@selector(scroll:) interval:0.005];
    }
    return self;
}

- (void) scroll:(ccTime)dt{
    int numBackgrounds = self.backgrounds.count;
    for(int i=0; i<numBackgrounds; i++) {
        CCSprite *background = [self.backgrounds objectAtIndex:i];
        background.position = ccp(background.position.x - self.scrollSpeed, background.position.y);
        if(background.position.x < -background.boundingBox.size.width) {
            int index = i-1;
            if(index < 0) index += numBackgrounds;
            CCSprite *leftBackground  = [self.backgrounds objectAtIndex:index];
            background.position = ccp(leftBackground.position.x + leftBackground.boundingBox.size.width, background.position.y);
        }
    }
}

@end
