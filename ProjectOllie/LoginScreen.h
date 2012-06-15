//
//  LoginScreen.h
//  ProjectOllie
//
//  Created by Lion User on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LoginScreen : CCLayer <UITextFieldDelegate>{
    
}
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *pwField;
@end
