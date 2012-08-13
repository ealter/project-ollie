//
//  GWWeaponTable.m
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWWeaponTable.h"
#import "MyCell.h"
#define kTagWepTable 10

@implementation GWWeaponTable


+(id)viewWithDataSource:(id<SWTableViewDataSource>)dataSource size:(CGSize)size{
    
    GWWeaponTable* tv  = [self viewWithDataSource:dataSource size:size container:nil];
    
    /* init values */
    tv.clipsToBounds = NO;
    [tv scheduleUpdate];
    
    return tv;
    
}

-(void)update:(ccTime) dt
{
    for (SWTableViewCell* cell in self->cellsUsed_) {
        
    }
}

-(void)removeSelf{
    [self.parent removeChild:[self.parent getChildByTag:kTagWepTable] cleanup:YES];
    [self.parent removeChild:self cleanup:YES];
}

//OVERRIDDEN NODE FUNCTIONS

-(void)setParent:(CCNode *)parent{
    parent_ = parent;
    /* label, you pleb! */
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Weapons" fontName:@"Marker Felt" fontSize:32];
    [self.parent addChild:label z:0 tag:kTagWepTable];
    [label setColor:ccc3(255,255,255)];
    label.position = self.position;
}

-(void)setPosition:(CGPoint)position{
    [super setPosition:position];
    if(self.parent)
        [[self.parent getChildByTag:kTagWepTable] setPosition:ccpAdd(position, ccp(0,self.contentSize.height/2.))];
}

/** 
 OVERRIDDEN TOUCH EVENTS
 **/
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!self.visible) {
        return NO;
    }
    CGRect frame;
    
    CGPoint tp = [touch locationInView:[touch view]];
    tp         = [[CCDirector sharedDirector] convertToGL:tp];
    tp         = [self.parent convertToNodeSpace:tp];
    frame = CGRectMake(self.position.x, self.position.y, viewSize_.width, viewSize_.height);
    
    //dispatcher does not know about clipping. reject touches outside visible bounds.
    if ([touches_ count] > 2 ||
     touchMoved_          ||
     !CGRectContainsPoint(frame, tp)) {
     return NO;
     }
    
    if (![touches_ containsObject:touch]) {
        [touches_ addObject:touch];
    }
    if ([touches_ count] == 1) { // scrolling
        touchPoint_     = tp;
        touchMoved_     = NO;
        isDragging_     = YES; //dragging started
        scrollDistance_ = ccp(0.0f, 0.0f);
        touchLength_    = 0.0f;
    } else if ([touches_ count] == 2) {
      touchPoint_  = ccpMidpoint([self convertTouchToNodeSpace:[touches_ objectAtIndex:0]],
      [self convertTouchToNodeSpace:[touches_ objectAtIndex:1]]);
      touchLength_ = ccpDistance([container_ convertTouchToNodeSpace:[touches_ objectAtIndex:0]],
      [container_ convertTouchToNodeSpace:[touches_ objectAtIndex:1]]);
      isDragging_  = NO;
      }
    return YES;
}
-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (!self.visible) {
        return;
    }
    if ([touches_ containsObject:touch]) {
        if ([touches_ count] == 1 && isDragging_) { // scrolling
            CGPoint moveDistance, newPoint, maxInset, minInset;
            CGRect  frame;
            CGFloat newX, newY;
            
            touchMoved_  = YES;
            frame        = CGRectMake(self.position.x, self.position.y, viewSize_.width, viewSize_.height);
            newPoint     = [touch locationInView:[touch view]];
            newPoint     = [[CCDirector sharedDirector] convertToGL: newPoint];
            newPoint     = [self.parent convertToNodeSpace:newPoint];
            moveDistance = ccpSub(newPoint, touchPoint_);

            touchPoint_  = newPoint;
            
            if (CGRectContainsPoint(frame, newPoint)) {
                switch (direction_) {
                    case SWScrollViewDirectionVertical:
                        moveDistance = ccp(0.0f, moveDistance.y);
                        break;
                    case SWScrollViewDirectionHorizontal:
                        moveDistance = ccp(moveDistance.x, 0.0f);
                        break;
                    default:
                        break;
                }
                container_.position = ccpAdd(container_.position, moveDistance);
                
                maxInset = maxInset_;
                minInset = minInset_;
                
                //check to see if offset lies within the inset bounds
                newX     = MIN(container_.position.x, maxInset.x);
                newX     = MAX(newX, minInset.x);
                newY     = MIN(container_.position.y, maxInset.y);
                newY     = MAX(newY, minInset.y);
                
                scrollDistance_     = ccpSub(moveDistance, ccp(newX - container_.position.x, newY - container_.position.y));
                [self setContentOffset:ccp(newX, newY)];
            }
        } else if ([touches_ count] == 2 && !isDragging_) {
            const CGFloat len = ccpDistance([container_ convertTouchToNodeSpace:[touches_ objectAtIndex:0]],
                                            [container_ convertTouchToNodeSpace:[touches_ objectAtIndex:1]]);
            [self setZoomScale:self.zoomScale*len/touchLength_];
        }
    }
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

@end
