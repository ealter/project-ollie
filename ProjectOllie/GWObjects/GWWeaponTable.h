//
//  GWWeaponTable.h
//  ProjectOllie
//
//  Created by Lion User on 8/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWTableView.h"

@interface GWWeaponTable : SWTableView

+(id)viewWithDataSource:(id<SWTableViewDataSource>)dataSource size:(CGSize)size characterName:(NSString*)name;
-(void)removeSelf;

@end

@interface GWWeaponTableSlot : CCNode{
    
}

@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* title;

@end
