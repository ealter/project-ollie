//
//  AppDelegate.h
//  ProjectOllie
//
//  Created by Eliot Alter on 5/31/12.
//  Copyright hi ku llc 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDirector.h"
@class CCDirectorIOS;

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, strong) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
