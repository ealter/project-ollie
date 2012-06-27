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
        //Shader testy stuff here
        CCSprite *sprite = [CCSprite spriteWithFile:@"white_clouds.jpeg"];
		sprite.anchorPoint = CGPointMake(0.5, 0.5);
		sprite.position = CGPointMake([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2);
		[self addChild:sprite];
        RippleEffect *ripple =[RippleEffect nodeWithTarget:sprite];
        [self addChild:ripple];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGSize tableViewSize = CGSizeMake(winSize.width, 100);
        tableView = [SWTableView viewWithDataSource:self size:tableViewSize];
        
        tableView.direction = SWScrollViewDirectionHorizontal;
        tableView.anchorPoint = ccp(0,0);
        tableView.position = ccp(0,0);
        tableView.contentOffset = ccp(0,0);
        tableView.delegate = self;
        tableView.verticalFillOrder = SWTableViewFillTopDown;
        
        [self addChild:tableView];
        [tableView reloadData];
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
        cell = [[MyCell new] autorelease];
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
