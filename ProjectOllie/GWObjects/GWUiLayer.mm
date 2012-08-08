//
//  GWUiLayer.m
//  ProjectOllie
//
//  Created by Lion User on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWUiLayer.h"
#import "MyCell.h"
#import "GWCharacter.h"
#import "GWWeapon.h"
#import "GWParticles.h"

@implementation GWUiLayer
@synthesize weaponTable         = _weaponTable;
@synthesize activeCharacter     = _activeCharacter;
@synthesize emitter             = _emitter;

-(id) init
{
	if(self = [super init]) {
        numCells                            = 0;
        self.weaponTable                    = NULL;
    }
	return self;
}

-(void)buildWeaponTableFrom:(GWCharacter *)character
{
    if (self.weaponTable == NULL) {
        CGSize winSize                      = [CCDirector sharedDirector].winSize;
        CGSize tableViewSize                = CGSizeMake(winSize.width, 100);
        self.weaponTable                    = [SWTableView viewWithDataSource:self size:tableViewSize];
        self.weaponTable.direction          = SWScrollViewDirectionHorizontal;
        self.weaponTable.anchorPoint        = CGPointZero;
        self.weaponTable.position           = CGPointZero;
        self.weaponTable.contentOffset      = CGPointZero;
        self.weaponTable.delegate           = self;
        self.weaponTable.verticalFillOrder  = SWTableViewFillTopDown;
        [self addChild:self.weaponTable];
    }else {
        if (self.activeCharacter != character) {
            self.activeCharacter    = character;
            numCells                = 0;
            wepIterator             = 0;
            
            //Count the number of unlocked weapons, for the table size
            numCells = [[character weapons] count];
            
            self.weaponTable.visible = YES;
            [self.weaponTable reloadData];
        }
    }
}

-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell
{
    
}

-(CGSize)cellSizeForTable:(SWTableView *)table
{
    return CGSizeMake(300, 100);
}

-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
    GWWeapon *loadWep = [[self.activeCharacter weapons]objectAtIndex:wepIterator];

    NSString *string = [NSString stringWithFormat:@"%d", loadWep.ammo];
    
    SWTableViewCell *cell = [table dequeueCell];
    if (!cell) {
        cell = [MyCell new];
        
        DebugLog(loadWep.weaponImage);
		CCSprite *sprite = [CCSprite spriteWithFile:loadWep.weaponImage];
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
    
    wepIterator ++;
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
