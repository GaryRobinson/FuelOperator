//
//  Facility+Additions.m
//  FuelOperator
//
//  Created by Gary Robinson on 11/23/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "Facility+Additions.h"

@implementation Facility (Additions)

+ (Facility *)updateOrCreateFromDictionary:(NSDictionary *)dict
{
    NSNumber *facilityID = [dict numberForKey:@"id"];
    Facility *facility = [Facility MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"facilityID == %d", [facilityID integerValue]]];
    if(!facility)
        facility = [Facility MR_createEntity];
    
    [facility updateFromDictionary:dict];
//    NSLog(@"saved facility with id %d", [facilityID intValue]);
    return facility;
}

- (void)updateFromDictionary:(NSDictionary *)dict
{
    self.facilityID = [dict numberForKey:@"id"];
    self.storeCode = [dict stringForKey:@"store_code"];
    self.address1 = [dict stringForKey:@"street1"];
    self.address2 = [dict stringForKey:@"street2"];
    self.city = [dict stringForKey:@"city"];
    self.state = [dict stringForKey:@"state"];
    self.zip = [dict stringForKey:@"postal_code"];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.lattitude = [f numberFromString:[dict stringForKey:@"latitude"]];
    self.longitude = [f numberFromString:[dict stringForKey:@"longitude"]];
}

@end
