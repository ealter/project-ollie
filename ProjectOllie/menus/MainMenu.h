//
//  MainMenu.h
//  ProjectOllie
//
//  Created by Lion User on 6/14/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "Menu.h"
#import "cocos2d.h"

@class CCLabelTTF;
@class CCParticleSystem;

@interface MainMenu: Menu {
    CCLabelTTF *userName;
}

//Emitter used for menu effects
@property (strong, nonatomic) CCParticleSystem *emitter;

-(void)finishButtonAndGoTo:(CCScene *) nextScene orCCBuilder:(NSString *) ccbiFile;

@end
