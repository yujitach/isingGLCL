//
//  isingAppDelegate.m
//  ising
//
//  Created by Yuji on 3/3/11.
//  Copyright 2011 Y. Tachikawa. All rights reserved.
//

#import "isingAppDelegate.h"
#import "GraphWindow.h"
@implementation isingAppDelegate

@synthesize window,beta,mag,//energy,
useCL;

#define REPEAT 10

-(void)randomizeSpin:(id)sender
{
    int i,j;
    for(j=0;j<SIZE;j++){
	spin[0][j]=-1;
	spin[SIZE-1][j]=-1;
    }
    for(i=0;i<SIZE;i++){
	spin[i][0]=-1;
	spin[i][SIZE-1]=-1;
    }
    for(i=1;i<SIZE-1;i++){
	for(j=1;j<SIZE-1;j++){
	    spin[i][j]=(random()%2)?1:-1;
	}
    }
}
uint32 rnglc (const uint32 v)
{
    const uint32 a = 1664525;
    const uint32 c = 1013904223;
    
    return a * v + c;
}
-(void)randomizeSeed:(id)sender
{
    int i,j;
    for(i=0;i<SIZE;i++){
	for(j=0;j<SIZE;j++){
	    seed[i][j]=random()&UINT32_MAX;
	}
    }
    for(i=0;i<SIZE;i++){
	for(j=0;j<SIZE;j++){
	    for(int k=0;k<10;k++){
		seed[i][j]=rnglc(seed[i][j]);
	    }
	}
    }
    
}
-(void)setupCL
{
    clContext=[[SMUGOpenCLContext alloc] initGPUContext];
/*
#if UseCLonGPU&&UseCLGLInterop
    clContext=[[SMUGOpenCLContext alloc] initGPUContextForGLContext:[iv openGLContext]];
    cl_mem texture=clCreateFromGLTexture2D([clContext context], 
					   CL_MEM_WRITE_ONLY, GL_TEXTURE_2D, 
					   0, [iv texture], NULL);
#endif
#if UseCLonGPU&&!UseCLGLInterop
    clContext=[[SMUGOpenCLContext alloc] initGPUContext];
#endif
#if !UseCLonGPU
    clContext=[[SMUGOpenCLContext alloc] initCPUContext];
#endif 
*/
    NSString*source=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ising" ofType:@"cl"]
					      encoding:NSUTF8StringEncoding
						 error:nil];
    clProgram=[[SMUGOpenCLProgram alloc] initWithContext:clContext
					    sourceString:source];
    clKernel=[clProgram kernelNamed:@"ising"];
#if UseGLCLInterop
    textureKernel=[clProgram kernelNamed:@"texture"];
#endif
}
-(void)setFactor:(int)f{
    [iv setFactor:f];
}
-(int)factor{
    return [iv factor];
}
-(void)setCritical:(id)sender{
    [self setBeta:log(1+sqrt(2))/2];
}
-(void)refreshGraph:(NSTimer*)timer{
    for(int d=0;d<XSEPARATION;d++){
        int num=0;
        double tot=0;
        for(int i=XSEPARATION;i<SIZE-XSEPARATION;i++){
            for(int j=XSEPARATION;j<SIZE-XSEPARATION;j++){
                num++;
                tot+=spin[i][j]*spin[i+d][j];
            }
        }
        corr[d]=tot/num;
    }
    if(gw){
        [gw feedDataPoints:corr];   
    }
}
-(IBAction)bringUp:(id)sender{
    if(!gw){
        gw=[[GraphWindow alloc] init];
    }
    [gw.window makeKeyAndOrderFront:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    [self randomizeSpin:self];
    [self randomizeSeed:self];
    [iv setSize:SIZE];
    [iv setArray:(void*)spin];
    [iv setNeedsDisplay:YES];
    [self setupCL];
    [self setUseCL:NO];
    [self setFactor:1];
    timer=[NSTimer timerWithTimeInterval:.1
				  target:self
				selector:@selector(step:)
				userInfo:nil
				 repeats:YES];
    graphTimer=[NSTimer timerWithTimeInterval:1
				  target:self
				selector:@selector(refreshGraph:)
				userInfo:nil
				 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer
				 forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer
				 forMode:NSEventTrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:graphTimer
				 forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:graphTimer
				 forMode:NSEventTrackingRunLoopMode];
    [self setCritical:self];
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
-(void)stepCL
{
    clSpin=clCreateBuffer(clContext.context, 
			  CL_MEM_USE_HOST_PTR|CL_MEM_READ_WRITE, sizeof(cl_int)*SIZE*SIZE, 
			  spin, NULL);
    clSeed=clCreateBuffer(clContext.context, 
			  CL_MEM_USE_HOST_PTR|CL_MEM_READ_WRITE, sizeof(cl_uint)*SIZE*SIZE, 
			  seed, NULL);
    clWeight=clCreateBuffer(clContext.context, 
			    CL_MEM_USE_HOST_PTR|CL_MEM_WRITE_ONLY, sizeof(cl_float)*9, 
			    weight, NULL);
    int size=SIZE;
    size_t globalWorkSize=SIZE*SIZE/2;
    for(int N=0;N<REPEAT;N++){
	unsigned int parity=0;
	[clKernel setArgument:0 withSize:sizeof(cl_uint) data:&size];
	[clKernel setArgument:1 withSize:sizeof(cl_mem) data:&clSpin];
	[clKernel setArgument:2 withSize:sizeof(cl_uint) data:&parity];
	[clKernel setArgument:3 withSize:sizeof(cl_mem) data:&clSeed];
	[clKernel setArgument:4 withSize:sizeof(cl_mem) data:&clWeight];
	[clContext enqueueKernel:clKernel
	      withWorkDimensions:1
		  globalWorkSize:&globalWorkSize
		   localWorkSize:NULL];
	parity=1;
	[clKernel setArgument:0 withSize:sizeof(cl_uint) data:&size];
	[clKernel setArgument:1 withSize:sizeof(cl_mem) data:&clSpin];
	[clKernel setArgument:2 withSize:sizeof(cl_uint) data:&parity];
	[clKernel setArgument:3 withSize:sizeof(cl_mem) data:&clSeed];
	[clKernel setArgument:4 withSize:sizeof(cl_mem) data:&clWeight];
	[clContext enqueueKernel:clKernel
	      withWorkDimensions:1
		  globalWorkSize:&globalWorkSize
		   localWorkSize:NULL];
    }
#if UseGLCLInterop
    [textureKernel setArgument:0 withSize:sizeof(cl_uint) data:&size];
    [textureKernel setArgument:1 withSize:sizeof(cl_mem) data:&clSpin];
    [textureKernel setArgument:2 withSize:sizeof(cl_mem) data:&texture];
    globalWorkSize=SIZE*SIZE;
    [clContext enqueueKernel:textureKernel
	  withWorkDimensions:1
	      globalWorkSize:&globalWorkSize
	       localWorkSize:NULL];
#endif
    clEnqueueReadBuffer(clContext.commandQueue, 
			clSpin,
		        NO, 0,
			sizeof(int)*SIZE*SIZE, spin, 0, NULL, NULL);
    clEnqueueReadBuffer(clContext.commandQueue, 
			clSeed,
		        YES, 0,
			sizeof(unsigned int)*SIZE*SIZE, seed, 0, NULL, NULL);
    clReleaseMemObject(clSeed);
    clReleaseMemObject(clSpin);
    clReleaseMemObject(clWeight);
}
-(void)stepNonCL
{
    for(int N=0;N<REPEAT;N++){
	for(int i=1;i<SIZE-1;i++){
	    for(int j=1;j<SIZE-1;j++){
		int m=spin[i][j]*(spin[i-1][j]+spin[i+1][j]+spin[i][j-1]+spin[i][j+1]);
		seed[i][j]=rnglc(seed[i][j]);
		double r=((double)(seed[i][j]))/UINT_MAX;
		if(weight[m+4]>r){
		    spin[i][j]=-spin[i][j];
		}
	    }
	}
    }
}
-(void)step:(NSTimer*)timer{
    for(int i=0;i<=8;i++){
	weight[i]=exp(-2*beta*(i-4));
    }
    if([self useCL]){
	[self stepCL];
    }else{
	[self stepNonCL];
    }
    double m=0;
    double e=0;
    for(int i=0;i<SIZE-1;i++){
	for(int j=0;j<SIZE-1;j++){
	    m+=spin[i][j];
            e+=spin[i][j]*(spin[i+1][j]+spin[i][j+1]);
	}
    }
    [self setMag:m/(SIZE-1)/(SIZE-1)];
 //   [self setEnergy:e/(SIZE-1)/(SIZE-1)];
    [iv setNeedsDisplay:YES];
}
@end
