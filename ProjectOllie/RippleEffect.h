//
//  RippleSprite.h
//  ProjectOllie
//
//  Created by Lion User on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"

@class CCNode;

@interface RippleEffect : CCSprite

/* Init with the node that will be rippled */
-(id)initWithSubject:(CCNode*)subject atOrigin:(CGPoint)origin;

/* The lifetime of the ripple effect */
@property (nonatomic) float lifetime;


@end
