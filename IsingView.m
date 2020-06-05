//
//  IsingView.m
//  ising
//
//  Created by Yuji on 3/4/11.
//  Copyright 2011 Y. Tachikawa. All rights reserved.
//

#import "IsingView.h"
#import <OpenGL/GL.h>
#define sqrtPi 1.7724



@implementation IsingView
@synthesize factor;
-(void)loadTextureFromArray
{
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, size, size, 0,
		 GL_LUMINANCE, GL_UNSIGNED_INT, array);
}
-(GLuint)texture{
    if(!textureReady){
	[[self openGLContext] makeCurrentContext];
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D,texture);
	[self loadTextureFromArray];
	textureReady=YES;
    }    
    return texture;
}
- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    if(!array)return;
    [self texture];
    glLoadIdentity();
    glOrtho(0, 1, 0, 1, -1.0, 1.0);
    glClearColor( 1.0, 1.0, 1.0, 1.0 );	
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
#if UseGLCLInterop
    glBindTexture(GL_TEXTURE_2D,texture);
#else
    [self loadTextureFromArray];
#endif
    glEnable(GL_TEXTURE_2D);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
    glBegin(GL_QUADS);{
	glTexCoord2f(0, 0);
	glVertex2f(0, 0);
	glTexCoord2f(1.0/factor, 0);
	glVertex2f(1, 0);
	glTexCoord2f(1.0/factor, 1.0/factor);
	glVertex2f(1, 1);
	glTexCoord2f(0, 1.0/factor);
	glVertex2f(0, 1);
    }glEnd();
    glDisable(GL_TEXTURE_2D);
    
    
    glFinish();
    [[self openGLContext] flushBuffer];
    
}
-(void)setSize:(int)s;
{
    size=s;
}
-(void)setArray:(int*)p;
{
    array=p;
}
@end
