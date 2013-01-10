//
//  GWShadowMappable.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 1/5/13.
//
//

#import <Foundation/Foundation.h>
#import "CCNode.h"

@protocol GWShadowMappable <CCNode>

@required
- (void)generateShadowMap;

@end
