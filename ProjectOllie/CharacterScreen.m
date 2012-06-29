//
//  CharacterScreen.m
//  ProjectOllie
//
//  Created by Lion User on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CharacterScreen.h"
#import "CCScrollView.h"
#import "SWTableViewCell.h"
#import "MyCell.h"
#import "cocos2d.h"
#import "RippleEffect.h"

@implementation CharacterScreen
@synthesize weaponScrollView;

-(id) init
{
	if(self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGSize tableViewSize = CGSizeMake(winSize.width, 100);
        tableView = [SWTableView viewWithDataSource:self size:tableViewSize];
        
        tableView.direction         = SWScrollViewDirectionHorizontal;
        tableView.anchorPoint       = CGPointZero;
        tableView.position          = CGPointZero;
        tableView.contentOffset     = CGPointZero;
        tableView.delegate          = self;
        tableView.verticalFillOrder = SWTableViewFillTopDown;
        
        [self addChild:tableView];
        [tableView reloadData];
        
        CCSprite *sprite2   = [CCSprite spriteWithFile:@"white_clouds.jpeg"];
		sprite2.anchorPoint = ccp(0.5, 0.5);
		sprite2.position    = ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2);
		[self addChild:sprite2];
        
        //RippleEffect *ripple =[[RippleEffect alloc] initWithParent:self];
        
    }
	return self;
}

-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell {
    
}

-(CGSize)cellSizeForTable:(SWTableView *)table {
    return CGSizeMake(300, 100);
}

-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx {
    
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

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    return 20;
}

-(void)pressedBack:(id)sender
{
    [self transitionToSceneWithFile:@"MainMenu.ccbi" removeUIViews:nil];
}

@end
