//
//  NSDate+Additions.h
//  FuelOperator
//
//  Created by Gary Robinson on 5/31/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

+ (NSTimeInterval)secondsPerDay;
+ (NSDate *)startOfToday;
+ (NSDate *)startOfTheWeekFromToday;
+ (NSDate *)startOfNextWeekFromToday;
+ (NSDate *)dateWithNumberOfDays:(NSInteger)days sinceDate:(NSDate*)date;
+ (NSDate *)getDateFromJSON:(NSString *)dateString;

@end
