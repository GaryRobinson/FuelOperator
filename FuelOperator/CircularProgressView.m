//
//  CircularProgressView.m
//  FuelOperator
//
//  Created by Gary Robinson on 10/27/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "CircularProgressView.h"

@implementation CircularProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect backgroundRect = CGRectMake(3, 3, self.bounds.size.width-6, self.bounds.size.height-6);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.667 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeEllipseInRect(context, backgroundRect);
    
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor fopOrangeColor].CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, self.bounds.size.width/2-4, -1 *M_PI_2, self.progress * 2. * M_PI - M_PI_2, 0);
    CGContextStrokePath(context);
    
    CGRect outsideBorderRect = CGRectMake(1, 1, self.bounds.size.width-2, self.bounds.size.height-2);
    CGContextSetStrokeColorWithColor(context, [UIColor fopLightGreyColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeEllipseInRect(context, outsideBorderRect);
    
    CGRect insideBorderRect = CGRectMake(6, 6, self.bounds.size.width-12, self.bounds.size.height-12);
    CGContextSetStrokeColorWithColor(context, [UIColor fopLightGreyColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeEllipseInRect(context, insideBorderRect);
    
    
//    CGContextFillEllipseInRect(context, circleRect);

}


@end
