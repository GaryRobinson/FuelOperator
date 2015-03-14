//
//  Inspection+Additions.m
//  FuelOperator
//
//  Created by Gary Robinson on 11/23/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "Inspection+Additions.h"

@implementation Inspection (Additions)

+ (Inspection *)updateOrCreateFromDictionary:(NSDictionary *)dict
{
    NSNumber *inspectionID = [dict numberForKey:@"id"];
    Inspection *inspection = [Inspection MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"inspectionID == %d", [inspectionID integerValue]]];
    if(!inspection)
        inspection = [Inspection MR_createEntity];
    
    [inspection updateFromDictionary:dict];
    return inspection;
}

- (void)updateFromDictionary:(NSDictionary *)dict
{
    self.user = [User loggedInUser];
    
    self.inspectionID = [dict numberForKey:@"id"];
    self.status = [dict stringForKey:@"status"];
    if([self.status isEqualToString:[Inspection statusClosed]])
        self.submitted = @(YES);
    else
        self.submitted = @(NO);
//    if([[dict objectForKey:@"stop"] boolValue])
//        self.submitted = @(YES);
    
    self.facilityID = [dict numberForKey:@"facility_id"];
    Facility *facility = [Facility MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"facilityID == %d", [self.facilityID intValue]]];
    self.facility = facility;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString *strDate = [dict objectForKey:@"scheduled"];
    self.date = [formatter dateFromString:strDate];
    
}

+ (NSString *)statusScheduled
{
    return @"Scheduled";
}
+ (NSString *)statusStarted
{
    return @"Started";
}
+ (NSString *)statusInProgress
{
    return @"In Process";
}
+ (NSString *)statusClosed
{
    return @"Closed";
}

@end
