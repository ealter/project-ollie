//
//  GWWater.m
//  ProjectOllie
//
//  Created by Lion User on 7/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GWWater.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "CCActionCatmullRom.h"


static CCGLProgram *shader_ = nil;
static int numVertices = 50; //The number of extra vertices on top of the water

@interface GWWater (){
    //Array of CGPoints to hold water shape
    NSMutableArray *waterPoly;
}

@property float waterHeight;

@end


@implementation GWWater
@synthesize waterHeight     = _waterHeight;

-(id)init
{
    if (self = [super init]) {
        CGSize s = [[CCDirector sharedDirector] winSize];

        self.waterHeight = s.height*0.3;
        
        
        //Code to make the water polygon
        //4 corners of the rectangle
        CGPoint tr = CGPointMake(s.width, self.waterHeight);
        [waterPoly addObject:[NSValue valueWithCGPoint:tr]];
        
        CGPoint br = CGPointMake(s.width, 0);
        [waterPoly addObject:[NSValue valueWithCGPoint:br]];

        CGPoint bl = CGPointMake(0, 0);
        [waterPoly addObject:[NSValue valueWithCGPoint:bl]];
        
        CGPoint tl = CGPointMake(0, self.waterHeight);
        [waterPoly addObject:[NSValue valueWithCGPoint:tl]];
        
        for (int i=0; i<numVertices; i++) {
            CGPoint p = CGPointMake(i*s.width/numVertices, self.waterHeight);
            [waterPoly addObject:[NSValue valueWithCGPoint:p]]; 
            //Get CGPoints with: CGPoint newPoint = [[waterPoly objectAtIndex:i] CGPointValue]
        }
            
        
        
        //Shader stufff
        GLchar *water_fsh = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WaterShader" ofType:@"fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        shader_ = [[CCGLProgram alloc] initWithVertexShaderByteArray:water_fsh fragmentShaderByteArray:ccPositionColor_frag];
        [shader_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [shader_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        [shader_ link];
        [shader_ updateUniforms];
        
        //Make the CGPoint[] to pass to the shader
        CGPoint verts[4+numVertices];
        for (int i = 0; i<(4+numVertices); i++) {
            verts[i] = [[waterPoly objectAtIndex:i] CGPointValue];
        }
        
        [self ccDrawSolidPoly:verts numPoints:4+numVertices withColor:ccc4f(0, 0, 255, 1)];
        
    }
    
    return self;
}

-(void) ccDrawSolidPoly: (CGPoint *)poli numPoints: (NSUInteger) numberOfPoints withColor:(ccColor4F) color
{    
	[shader_ use];
	[shader_ setUniformForModelViewProjectionMatrix];    
	[shader_ setUniformLocation:-1 with4fv:(GLfloat*) &color.r count:1];
    
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
	// XXX: Mac OpenGL error. arrays can't go out of scope before draw is executed
	ccVertex2F newPoli[numberOfPoints];
    
	// iPhone and 32-bit machines optimization
	if( sizeof(CGPoint) == sizeof(ccVertex2F) )
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, poli);
	
	else
    {
		// Mac on 64-bit
		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoli[i] = (ccVertex2F) { poli[i].x, poli[i].y };
		
		glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, newPoli);
	}    
    
	glDrawArrays(GL_TRIANGLE_FAN, 0, (GLsizei) numberOfPoints);
}

@end
