//
//  GraphWindow.h
//  ising
//
//  Created by 立川 裕二 on 11/08/23.
//  Copyright (c) 2011年 東京大学. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define XSEPARATION 150
#define CUTOFF 0.01

@class SM2DGraphView;
@interface GraphWindow : NSWindowController
{
    SM2DGraphView*graphView;
    double*dataPoints;
}
@property (assign) BOOL xLog;
@property (assign) BOOL yLog;
@property (assign) BOOL theo;
@property (retain) IBOutlet  SM2DGraphView*graphView;
-(void)feedDataPoints:(double*)d;
@end
