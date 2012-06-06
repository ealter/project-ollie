//
//  ccVertTypes.h
//  ProjectOllie
//
//  Created by Lion User on 6/5/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#ifndef ProjectOllie_ccVertTypes_h
#define ProjectOllie_ccVertTypes_h

#import <OpenGLES/ES2/gl.h>

/** A vertex composed of 2 GLfloats: x, y
 @since v0.8
 */
typedef struct _ccVertex2F
{
	GLfloat x;
	GLfloat y;
} ccVertex2F;

/** A vertex composed of 2 floats: x, y
 @since v0.8
 */
typedef struct _ccVertex3F
{
	GLfloat x;
	GLfloat y;
	GLfloat z;
} ccVertex3F;

#endif
