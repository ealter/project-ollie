//
//  GWGestures.m
//  ProjectOllie
//
//  Created by Lion User on 7/18/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWGestures.h"
#import "cocos2d.h"
#import "GWParticles.h"
#import "GWCharacter.h"
#import "MyCell.h"
#import "GWWeapon.h"



@interface GWGestures ()
{
    //location of first touch
    CGPoint touchDown;
    
    //location of the moving touch
    CGPoint touchMove;
    
    //location of the last touch
    CGPoint touchUp;
    
    //time of first touch
    double touchDownTime;
    
    //current time of the touch
    double touchTime;
    
    //boolean for pan checking
    BOOL isPanning;
}

@end

@implementation GWGestures
@synthesize children        = _children;
@synthesize activeCharacter = _activeCharacter;
@synthesize emitter         = _emitter;
@synthesize touchTarget     = _touchTarget;
@synthesize weaponView      = _weaponView;
    
-(id)init
{
    if (self = [super init]) {
        self.isTouchEnabled               = YES;
        self.children                     = [NSMutableArray array];
        numCells                          = 0;
        CGSize winSize                    = [CCDirector sharedDirector].winSize;
        CGSize tableViewSize              = CGSizeMake(winSize.width, 100);
        self.weaponView                   = [SWTableView viewWithDataSource:self size:tableViewSize];
        
        self.weaponView.direction         = SWScrollViewDirectionHorizontal;
        self.weaponView.anchorPoint       = CGPointMake(0, 0);
        self.weaponView.position          = CGPointMake(0, 0);
        self.weaponView.contentOffset     = CGPointZero;
        self.weaponView.delegate          = self;
        self.weaponView.verticalFillOrder = SWTableViewFillTopDown;
        self.weaponView.visible           = NO;
        
        [self addChild:self.weaponView];
    }
    
    return self;
}

-(void)buildWeaponTableFrom:(GWCharacter *)character
{
    if (self.activeCharacter != character) {
        self.activeCharacter    = character;
        numCells                = 0;
        
        //Count the number of unlocked weapons, for the table size
        for (int  i = 0; i < [[character weapons] count]; i++) {
            GWWeapon * wep = [[character weapons] objectAtIndex:i];
            if (wep.unlocked) {
                numCells ++;
            }
        }
        self.weaponView.visible = YES;
        [self.weaponView reloadData];
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{    
    //Get the first touch's location and time
    touchDown = [touch locationInView: touch.view];
    touchDownTime = [touch timestamp];
    touchDown = [[CCDirector sharedDirector] convertToGL:touchDown];
    touchDown = [self convertToNodeSpace:touchDown];
    isPanning = NO;
    
    for (CCNode<GestureChild> *child in self.children) {
        if (ccpDistance(touchDown, child.position) < 50) {
            self.touchTarget = child;
            return YES;
        }
    }
    return NO;
}


-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{    
    touchMove = [touch locationInView:touch.view];
    touchMove = [[CCDirector sharedDirector] convertToGL:touchMove];
    touchMove = [self convertToNodeSpace:touchMove];
    touchTime = [touch timestamp] - touchDownTime;
    
    if (isPanning) {
        //Handle a pan            
        [self.touchTarget handlePanWithStart:touchDown andCurrent:touchMove andTime:touchTime];
    }else {
        if (ccpDistance(touchDown, touchMove) > 5) {
            //This is a pan, or a swipe
            if (touchTime >0.2) {
                //This is a pan
                isPanning = YES;
            }
        }
    }
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    touchUp = [touch locationInView:touch.view];
    touchUp = [[CCDirector sharedDirector] convertToGL:touchUp];
    touchUp = [self convertToNodeSpace:touchUp];
    touchTime = [touch timestamp] - touchDownTime;    
    
    if (isPanning) {
        //That was a Pan
        [self.touchTarget handlePanFinishedWithStart:touchDown andEnd:touchMove andTime:touchTime];
    }else if (touchTime < 0.2 && ccpDistance(touchDown, touchUp) > 15) {
        //This means a swipe!
        
        //Calculate swipe direction: left, right, up down
        CGPoint swipeVec = ccpSub(touchUp, touchDown);
        float angle = atan2f(touchUp.x-touchDown.x, touchUp.y-touchDown.y);
        float len   = ccpDistance(touchDown, touchUp);
        float vel   = len / touchTime;
        if (swipeVec.x > 10 && abs(swipeVec.x) > abs(swipeVec.y)) {
            //Swipe to the right
            [self.touchTarget handleSwipeRightWithAngle:angle andLength:len andVelocity:vel];
        }else if (swipeVec.x < -10 && abs(swipeVec.x) > abs(swipeVec.y)) {
            //Swipe to the left
            [self.touchTarget handleSwipeLeftWithAngle:angle andLength:len andVelocity:vel];
        }else if (swipeVec.y < -10 && abs(swipeVec.y) > abs(swipeVec.x)) {
            //Swipe upwards
            [self.touchTarget handleSwipeUpWithAngle:angle andLength:len andVelocity:vel];
        }else if (swipeVec.y > 10 && abs(swipeVec.y) > abs(swipeVec.x)) {
            //Swipe downwards
            [self.touchTarget handleSwipeDownWithAngle:angle andLength:len andVelocity:vel];
        }
        
    }else if (touchTime < 0.2 && ccpDistance(touchDown, touchUp) <= 15) {
        //This means a tap!
            [self.touchTarget handleTap:touchUp];
    }
}

- (void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];

}

//Table methods
-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell
{
    
}

-(CGSize)cellSizeForTable:(SWTableView *)table
{
    return CGSizeMake(300, 100);
}

-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
    NSString *string = [NSString stringWithFormat:@"%d", idx];
    
    SWTableViewCell *cell = [table dequeueCell];
    if (!cell) {
        cell = [MyCell new];
		CCSprite *sprite = [CCSprite spriteWithFile:@"back-hd.png"];
		sprite.anchorPoint = CGPointZero;
        
		[cell addChild:sprite];
		CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:@"Helvetica" fontSize:20.0];
		label.position = ccp(20, 20);
		label.tag = 123;
		[cell addChild:label];
	}
	else {
		CCLabelTTF *label = (CCLabelTTF*)[cell getChildByTag:123];
		[label setString:string];
	}
    
    return cell;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table
{
    if (numCells == 0) {
        return 1;
    }else {
        return numCells;
    }
}

//Override methods
-(void)setActiveCharacter:(GWCharacter *)activeCharacter
{
    _activeCharacter        = activeCharacter;
    self.emitter            = [GWParticleExplodingRing node];
    self.emitter.position   = activeCharacter.position;
    [self.parent addChild:self.emitter];
    
}

@end
