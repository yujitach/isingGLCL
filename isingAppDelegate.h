//
//  isingAppDelegate.h
//  ising
//
//  Created by Yuji on 3/3/11.
//  Copyright 2011 Y. Tachikawa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IsingView.h"
#import "SMUGOpenCL.h"
#import "GraphWindow.h"

#define SIZE 1024
@interface isingAppDelegate : NSObject <NSApplicationDelegate> {
    double energy;
    IBOutlet IsingView*iv;
    GraphWindow*gw;
    double corr[XSEPARATION];
    NSTimer*timer;
    NSTimer*graphTimer;
    cl_int spin[SIZE][SIZE];
    cl_uint seed[SIZE][SIZE];
    cl_float weight[9];
    cl_mem clSpin;
    cl_mem clSeed;
    cl_mem clWeight;
    cl_mem texture;
    SMUGOpenCLContext*clContext;
    SMUGOpenCLProgram*clProgram;
    SMUGOpenCLKernel*clKernel;
    SMUGOpenCLKernel*textureKernel;
}

@property (retain) IBOutlet NSWindow *window;
@property (assign) BOOL useCL;
@property (assign) double beta;
@property (assign) double mag;
//@property (assign) double energy;
-(IBAction)setCritical:(id)sender;
-(IBAction)bringUp:(id)sender;
-(void)setupCL;
@end
