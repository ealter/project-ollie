//
//  GWWeaponTable.m
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWWeaponTable.h"
#import "GWWeapon.h"
#import "MyCell.h"
#define kTagWepTable 10
#define kTableSizeMultiplier 2.4

@interface GWWeaponTable()
{
    
}
-(void)setOpacity;
-(CGRect)touchRect;

@end

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
    

}

-(void)removeSelf{
    [self.parent removeChild:[self.parent getChildByTag:kTagWepTable] cleanup:YES];
    [self.parent removeChild:self cleanup:YES];
}

-(void)setOpacity{
    float numIndices = [self.dataSource numberOfCellsInTableView:self]-1;
    float cellWidth      = [self.dataSource cellSizeForTable:self].width;
    for (int i = 0; i < numIndices + 1; i++)
    {
        SWTableViewCell* cell = [self cellAtIndex:i];
        if(cell && cell.children.count > 1)
        {
            GWWeapon* sprite  = [cell.children objectAtIndex:0];
            CCLabelTTF* label = [cell.children objectAtIndex:1];
            
            float distance   = abs(self.contentOffset.x);
            float index      = cell.idx;
            float indexRatio = index/numIndices;
            
            float spriteDist = indexRatio * numIndices * cellWidth; 
            float opacity    = max(0,-1. * pow(abs(spriteDist - distance),1.2)  + 255);
            
            [sprite setOpacity:opacity];
            [label setOpacity:opacity];
        }
    }

}

//OVERRIDDEN NODE FUNCTIONS

-(void)setParent:(CCNode *)parent{
    parent_ = parent;
    /* label, you pleb! */
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Weapons" fontName:@"Aaargh" fontSize:32];
    [self.parent addChild:label z:0 tag:kTagWepTable];
    [label setColor:ccc3(255,255,255)];
    label.position = self.position;
}

-(void)setPosition:(CGPoint)position{
    [super setPosition:position];
    if(self.parent)
        [[self.parent getChildByTag:kTagWepTable] setPosition:ccpAdd(position, ccp(0,self.contentSize.height/2.))];
}

-(void)draw{
    [self setOpacity];
    [super draw];
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
    
    frame = [self touchRect];
    
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
            frame        = [self touchRect];
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

-(CGRect)touchRect{
    return CGRectMake(self.position.x - viewSize_.width * kTableSizeMultiplier, self.position.y - viewSize_.width*kTableSizeMultiplier,2*kTableSizeMultiplier*viewSize_.width, 2*viewSize_.height*kTableSizeMultiplier);
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

@end
