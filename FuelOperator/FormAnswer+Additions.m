//
//  FormAnswer+Additions.m
//  FuelOperator
//
//  Created by Gary Robinson on 8/28/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "FormAnswer+Additions.h"

@implementation FormAnswer (Additions)

- (BOOL)isAnswered
{
    if([self.answer integerValue] == kUnanswered)
        return NO;
    
    if([self needsComment])
        return NO;
    
    if([self needsPhoto])
        return NO;
    
    return YES;
//    if([self.answer integerValue] == kYES)
//        return YES;
//    
//    if(self.photos.count > 0/* self.comment && ![self.comment isEqualToString:@""]*/)
//        return YES;
//    else
//        return NO;
}

- (BOOL)needsComment
{
    if([self.formQuestion.forceComment boolValue] && [[self commentText] isEqualToString:@""])
        return YES;
    
    return NO;
}
- (BOOL)needsPhoto
{
    if([self.formQuestion.imageRequired boolValue] && self.photos.count <= 0)
        return YES;
    
    return NO;
}

- (NSString *)answerText
{
    if([self.answer integerValue] == kYES)
        return @"T";
    else if([self.answer integerValue] == kUnanswered)
        return @" ";
    
    return @"F";
}

- (NSString *)commentText
{
    if(!self.comment)
        return @"";
    
    return self.comment;
}

+ (FormAnswer *)updateOrCreateFromDictionary:(NSDictionary *)answerDict andInspection:(Inspection *)inspection
{
//    NSLog(@"update answer from dict");
    
    NSNumber *recordID = [answerDict numberForKey:@"record_id"];
    FormAnswer *answer = [FormAnswer MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"recordID == %d", [recordID integerValue]]];
    if(!answer)
    {
        answer = [FormAnswer MR_createEntity];
        answer.inspection = inspection;
    }
    
    [answer updateFromDictionary:answerDict];
    return answer;
}

- (void)updateFromDictionary:(NSDictionary *)dict
{
    self.recordID = [dict numberForKey:@"record_id"];
    
    //?? it could be a date or string, not necessarily a number
    NSObject *unknownAnswer = dict[@"answer"];
    if([unknownAnswer isKindOfClass:[NSString class]])
    {
        self.answer = @(YES);
        //probably want to save the answer
    }
    else
        self.answer = [dict numberForKey:@"answer"];
    
    
    //no is probably 0, I need to change it to my enum
    if([self.answer intValue] == 0)
        self.answer = @(kNO);
    
    self.type = [dict stringForKey:@"answer_type"];
    self.comment = [dict stringForKey:@"Comments"];
    
    //?? link it to a question
    FormQuestion *question = [FormQuestion MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"recordID == %d", [self.recordID integerValue]]];
    self.formQuestion = question;
    
    self.repairedOnSite = @(NO);
    if(dict[@"repaired_on_site"] && dict[@"repaired_on_site"] != [NSNull null])
        self.repairedOnSite = @([dict[@"repaired_on_site"] boolValue]);
    
    
    
}


@end
