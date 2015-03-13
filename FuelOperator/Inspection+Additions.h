//
//  Inspection+Additions.h
//  FuelOperator
//
//  Created by Gary Robinson on 11/23/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "Inspection.h"

@interface Inspection (Additions)

+ (Inspection *)updateOrCreateFromDictionary:(NSDictionary *)dict;
- (void)updateFromDictionary:(NSDictionary *)dict;

+ (NSString *)statusScheduled;
+ (NSString *)statusStarted;
+ (NSString *)statusInProgress;
+ (NSString *)statusClosed;

@end
