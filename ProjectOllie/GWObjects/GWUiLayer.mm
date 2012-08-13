//
//  GWUILayer.m
//  ProjectOllie
//
//  Created by Lion User on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWUILayer.h"
#import "MyCell.h"
#import "GWCharacterAvatar.h"
#import "GWWeapon.h"
#import "GWParticles.h"

@implementation GWUILayer
@synthesize weaponTable         = _weaponTable;
@synthesize activeCharacter     = _activeCharacter;
@synthesize emitter             = _emitter;

-(id) init
{
	if(self = [super init]) {
        numCells                            = 0;
        self.weaponTable                    = NULL;
        [self scheduleUpdate];
    }
	return self;
}

-(void)buildWeaponTableFrom:(GWCharacterAvatar *)character
{
    if (!self.weaponTable) {
        
        if (self.activeCharacter != character) {
            self.activeCharacter    = character;
            numCells                = 0;
            
            //Count the number of weapons, for the table size
            numCells = [[character weapons] count];
        }

        CGSize tableViewSize                = CGSizeMake(250, 100);
        self.weaponTable                    = [GWWeaponTable viewWithDataSource:self size:tableViewSize];
        self.weaponTable.direction          = SWScrollViewDirectionHorizontal;
        self.weaponTable.anchorPoint        = CGPointZero;
        CGPoint tablePos                    = self.activeCharacter.position;
        self.weaponTable.position           = ccpAdd(tablePos, CGPointMake(0, 90));
        self.weaponTable.contentOffset      = CGPointZero;
        self.weaponTable.delegate           = self;
        self.weaponTable.verticalFillOrder  = SWTableViewFillTopDown;
        [self addChild:self.weaponTable];
    }
    else {
        if (self.activeCharacter != character) {
            
            self.activeCharacter    = character;
            
            //Count the number of weapons, for the table size
            numCells = [[character weapons] count];
            
            //Position of the table should be moved around to new character!
            CGPoint tablePos                = [self convertToWorldSpace:self.activeCharacter.position];
            self.weaponTable.position       = ccpAdd(tablePos, CGPointMake(0, 10));  
            
            [self.weaponTable reloadData];
        }
    }
}

-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell
{
    [self.weaponTable.parent removeChild:self.weaponTable cleanup:YES];
    self.weaponTable                = nil;
    _activeCharacter.selectedWeapon = [_activeCharacter.weapons objectAtIndex:cell.idx];
    _activeCharacter                = nil;
}

-(CGSize)cellSizeForTable:(SWTableView *)table
{
    return CGSizeMake(100, 100);
}

-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
    GWWeapon *loadWep = [[self.activeCharacter weapons]objectAtIndex:idx];

    NSString *string = [NSString stringWithFormat:@"%d", idx];
    
    
    SWTableViewCell *cell = [table cellAtIndex:idx];
    if (!cell) {
        cell = [MyCell new];
        
		CCSprite *sprite = [CCSprite spriteWithFile:loadWep.weaponImage];
		sprite.anchorPoint = CGPointZero;
        
		[cell addChild:sprite];
		CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:@"Helvetica" fontSize:15.0];
		label.position = ccp(20, 20);
		label.tag = 123;
		[cell addChild:label];
	}
    
    return cell;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table
{
    return numCells;
}

//Override methods
-(void)setActiveCharacter:(GWCharacterAvatar *)activeCharacter
{
    if(activeCharacter)
    {
        _activeCharacter        = activeCharacter;
        self.emitter            = [GWParticleExplodingRing node];
        self.emitter.position   = activeCharacter.position;
        [self.parent addChild:self.emitter];
    }
}

-(void)update:(float)dt{
    CGPoint tablePos                    = self.activeCharacter.position;
    self.weaponTable.position           = ccpAdd(tablePos, CGPointMake(0, 90));

}

@end
