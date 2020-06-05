//
//  GraphWindow.m
//  ising
//
//  Created by 立川 裕二 on 11/08/23.
//  Copyright (c) 2011年 東京大学. All rights reserved.
//
#import "SM2DGraphView.h"
#import "GraphWindow.h"

@implementation GraphWindow
@synthesize graphView,theo,xLog,yLog;
- (id)init
{
    self = [super initWithWindowNibName:@"GraphWindow"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setXLog:YES];
    [self setYLog:YES];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark graph view data source / delegate methods
-(void)feedDataPoints:(double*)d;
{
    dataPoints=d;
    for(int i=0;i<XSEPARATION;i++){
        if(dataPoints[i]<CUTOFF){
            dataPoints[i]=CUTOFF;
        }
    }
    [graphView setDrawsGrid:NO];
    [graphView refreshDisplay:self];
}
- (unsigned int)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView; 
{
    if(!dataPoints){
        return 0;
    }
    if(theo){
        return 2;
    }else{
        return 1;
    }
}
- (CGFloat)twoDGraphView:(SM2DGraphView *)inGraphView maximumValueForLineIndex:(unsigned int)inLineIndex
                 forAxis:(SM2DGraphAxisEnum)inAxis; 
{
    if(inAxis==kSM2DGraph_Axis_X) {
	return xLog?log(XSEPARATION):XSEPARATION;
    }else{ //Y
	return yLog?log(1):1;
    }
}
- (CGFloat)twoDGraphView:(SM2DGraphView *)inGraphView minimumValueForLineIndex:(unsigned int)inLineIndex
                 forAxis:(SM2DGraphAxisEnum)inAxis; 
{
    if(inAxis==kSM2DGraph_Axis_X) {
	return xLog?log(5):5;
    }else{ //Y
	return yLog?log(CUTOFF):CUTOFF;
    }    
}
- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView dataForLineIndex:(unsigned int)inLineIndex; 
{
    if(inLineIndex==0){
        NSMutableArray*a=[NSMutableArray array];
        for(int i=5;i<XSEPARATION;i++){
            NSPoint point=NSMakePoint(xLog?log(i):i, yLog?log(dataPoints[i]):dataPoints[i]);
            NSString*s=NSStringFromPoint(point);
            [a addObject:s];
        }
        return a;  
    }else{
        NSMutableArray*a=[NSMutableArray array];
        for(int i=5;i<XSEPARATION;i++){
            double the=log(dataPoints[10])-1.0/4*log(i/10.0);
            NSPoint point=NSMakePoint(xLog?log(i):i, yLog?the:exp(the));
            NSString*s=NSStringFromPoint(point);
            [a addObject:s];
        }
        return a;        
    }
}
- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView attributesForLineIndex:(unsigned int)inLineIndex; 
{
    NSMutableDictionary*dict=[NSMutableDictionary dictionary];
    if(inLineIndex==0){
        [dict setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
        [dict setObject:[ NSNumber numberWithInt:kSM2DGraph_Symbol_Diamond ] forKey:SM2DGraphLineSymbolAttributeName];
    }else{
        [dict setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];        
    }
    return dict;
}
@end
