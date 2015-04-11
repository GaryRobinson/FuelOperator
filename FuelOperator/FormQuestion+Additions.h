//
//  FormQuestion+Additions.h
//  FuelOperator
//
//  Created by Gary Robinson on 11/23/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "FormQuestion.h"

@interface FormQuestion (Additions)

+ (FormQuestion *)updateOrCreateFromDictionary:(NSDictionary *)dict andInspection:(Inspection *)inspection;
- (void)updateFromDictionary:(NSDictionary *)dict;

+ (NSString *)typeFacility;
+ (NSString *)typeTanks;
+ (NSString *)typeDispensers;

+ (NSString *)yesNoType;
+ (NSString *)dateType;

- (BOOL)isYesNo;
- (BOOL)isDate;

@end
