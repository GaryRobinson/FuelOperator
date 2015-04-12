//
//  UIColor+Additions.m
//  FuelOperator
//
//  Created by Gary Robinson on 2/26/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor *)fopLightGreyColor
{
    return [self colorWithRed:153/255. green:153/255. blue:153/255. alpha:1.0];
}

+ (UIColor *)fopDarkText
{
    return [self colorWithRed:76/255. green:76/255. blue:81/255. alpha:1.0];
}

+ (UIColor *)fopRegularText
{
    return [self colorWithRed:102/255. green:102/255. blue:102/255. alpha:1.0];
}

+ (UIColor *)fopDarkGreyColor
{
    return [self colorWithRed:34/255. green:38/255. blue:43/255. alpha:1.0];
}

+ (UIColor *)fopYellowColor
{
    return [self colorWithRed:246/255. green:174/255. blue:106/255. alpha:1.0];
}

+ (UIColor *)fopOffWhiteColor
{
    return [self colorWithRed:221/255. green:221/255. blue:221/255. alpha:1.0];
}

+ (UIColor *)fopWhiteColor
{
    return [self colorWithRed:239/255. green:239/255. blue:239/255. alpha:1.0];
}

+ (UIColor *)fopProgressBackgroundColor
{
    return [self colorWithRed:84/255. green:84/255. blue:96/255. alpha:1.0];
}

@end
