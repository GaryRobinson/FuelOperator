//
//  FormQuestion+Additions.m
//  FuelOperator
//
//  Created by Gary Robinson on 11/23/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "FormQuestion+Additions.h"

@implementation FormQuestion (Additions)

+ (FormQuestion *)updateOrCreateFromDictionary:(NSDictionary *)dict andInspection:(Inspection *)inspection
{
    NSNumber *recordID = [dict numberForKey:@"record_id"];
    FormQuestion *question = [FormQuestion MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"recordID == %d", [recordID integerValue]]];
    if(!question)
    {
        question = [FormQuestion MR_createEntity];
        question.inspection = inspection;
    }
    
    [question updateFromDictionary:dict];
    return question;
}

- (void)updateFromDictionary:(NSDictionary *)dict
{
    self.recordID = [dict numberForKey:@"record_id"];
    self.questionID = [dict stringForKey:@"question_id"];
    //??self.groupID = [dict numberForKey:@"GroupID"];
    self.type = [dict stringForKey:@"category"];
    self.mainCategory = [dict stringForKey:@"category"];
    self.subCategory = [dict stringForKey:@"subcategory"];
    self.question = [dict stringForKey:@"question"];
    self.forceComment = [dict numberForKey:@"comment_required"];
//    self.answerRequired = [dict numberForKey:@"AnswerRequired"];
    self.imageRequired = [dict numberForKey:@"photo_required"];
    self.componentID = [dict stringForKey:@"component_id"];
    self.answerType = [dict stringForKey:@"answer_type"];
    
    //?? what about:
    //record_id
    //component_id
    //component_id_field_name
//    NSLog(@"saved question recordID=%d, inspectionID=%d", [self.recordID intValue], [self.inspection.inspectionID intValue]);
}

+ (NSString *)typeFacility
{
    return @"Facility";
}

+ (NSString *)typeTanks
{
    return @"Tanks";
}

+ (NSString *)typeDispensers
{
    return @"Dispenser";
}

+ (NSString *)yesNoType
{
    return @"Yes/No";
}
+ (NSString *)dateType
{
    return @"Date Field";
}
+ (NSString *)userEnteredType
{
    return @"User Entered";
}

- (BOOL)isYesNo
{
    return [self.answerType isEqualToString:[FormQuestion yesNoType]];
}
- (BOOL)isDate
{
    return [self.answerType isEqualToString:[FormQuestion dateType]];
}
- (BOOL)isUserEntered
{
    return [self.answerType isEqualToString:[FormQuestion userEnteredType]];
}

@end
