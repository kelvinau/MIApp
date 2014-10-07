//
//  DrawGreyRectUIView.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-02.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "DrawRedRectUIView.h"

@implementation DrawRedRectUIView

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect rectangle = rect;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0);   //this is the transparent color
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    CGContextFillRect(context, rectangle);
    CGContextStrokeRect(context, rectangle);    //this will draw the border
    
}

@end
