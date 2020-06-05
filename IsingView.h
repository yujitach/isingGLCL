//
//  IsingView.h
//  ising
//
//  Created by Yuji on 3/4/11.
//  Copyright 2011 Y. Tachikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define UseGLCLInterop 0

@interface IsingView : NSOpenGLView {
    int size;
    int*array;
    BOOL textureReady;
    GLuint texture;
}
-(void)setSize:(int)s;
-(void)setArray:(int*)p;
-(GLuint)texture;
@property (assign) int factor;
@end
