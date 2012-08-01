//
//  DrawMenu.h
//  ProjectOllie
//
//  Created by Lion User on 6/11/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"

@protocol DrawMenu_delegate <NSObject>

- (void)DrawMenu_setBrushRadius:(CGFloat)radius;
- (void)DrawMenu_doneDrawing;
- (void)DrawMenu_clearDrawing;

@end

@interface DrawMenu : Menu

@property (nonatomic, assign) id <DrawMenu_delegate> delegate;

@end
