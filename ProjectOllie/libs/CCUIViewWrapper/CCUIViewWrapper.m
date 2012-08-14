/* 
 * CCUIViewWrapper
 *
 * http://www.cocos2d-iphone.org/forum/topic/6889
 *
 * Copyright (C) 2010 Blue Ether
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 * version 1.0.1 by bitfool
 *
 */

#import "CCUIViewWrapper.h"
#import "cocos2d.h"

@implementation CCUIViewWrapper

@synthesize uiItem;

+ (id) wrapperForUIView:(UIView*)ui
{
	return [[self alloc] initForUIView:ui];
}

- (id) initForUIView:(UIView*)ui
{
	if((self = [self init]))
	{
		self.uiItem = ui;
		return self;
	}
	return nil;
}

- (void) dealloc
{
	self.uiItem = nil;
}

-(void)setParent:(CCNode *)parent {
	if(parent == nil) {
		[uiItem removeFromSuperview];
    } else if(uiItem != nil) {
        [[[CCDirector sharedDirector] view] addSubview:uiItem];
    }
	[super setParent:parent];
}

-(void)updateUIViewTransform {
	float thisAngle, pAngle;
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0, [[CCDirector sharedDirector] winSize].height);
    
	for(CCNode *p = self; p != nil; p = p.parent) {
		thisAngle = CC_DEGREES_TO_RADIANS(p.rotation);
        if(p.ignoreAnchorPointForPosition)
			transform = CGAffineTransformTranslate(transform, p.anchorPointInPoints.x, p.anchorPointInPoints.y);
        
		if(p.parent != nil) {
			pAngle = CC_DEGREES_TO_RADIANS(p.parent.rotation);
            
			transform = CGAffineTransformTranslate(transform,
                                                   (p.position.x * cosf(pAngle))+(p.position.y * sinf(pAngle)),
                                                   (-p.position.y * cosf(pAngle))+(p.position.x * sinf(pAngle)));
        }
		else {
			transform = CGAffineTransformTranslate(transform, p.position.x, -p.position.y);
        }
        
		transform = CGAffineTransformRotate(transform, thisAngle);
		transform = CGAffineTransformScale(transform, p.scaleX, p.scaleY);
		transform = CGAffineTransformTranslate(transform, -p.anchorPointInPoints.x, -p.anchorPointInPoints.y);
    }
    
	[uiItem setTransform:transform];
}

- (void) setVisible:(BOOL)v
{
	[super setVisible:v];
	[uiItem setHidden:!v];
}

- (void) setRotation:(float)protation
{
	[super setRotation:protation];
	[self updateUIViewTransform];
}

- (void) setScaleX:(float)sx
{
	[super setScaleX:sx];
	[self updateUIViewTransform];
}

- (void) setScaleY:(float)sy
{
	[super setScaleY:sy];
	[self updateUIViewTransform];
}

- (void) setOpacity:(GLubyte)opacity
{
	[uiItem setAlpha:opacity/255.0];
	[super setOpacity:opacity];
}

- (void) setContentSize:(CGSize)size
{
	[super setContentSize:size];
	uiItem.frame	= CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
	uiItem.bounds	= CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (void) setAnchorPoint:(CGPoint)pnt
{
	[super setAnchorPoint:pnt];
	[self updateUIViewTransform];
}

- (void) setPosition:(CGPoint)pnt
{
	[super setPosition:pnt];
	[self updateUIViewTransform];
}

@end
