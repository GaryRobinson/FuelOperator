//
//  Inspection.h
//  FuelOperator
//
//  Created by Gary Robinson on 3/13/15.
//  Copyright (c) 2015 GaryRobinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Facility, FormAnswer, FormQuestion, User;

@interface Inspection : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * inspectionID;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSNumber * scheduleID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * submitted;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSNumber * facilityID;
@property (nonatomic, retain) Facility *facility;
@property (nonatomic, retain) NSSet *formAnswers;
@property (nonatomic, retain) NSSet *formQuestions;
@property (nonatomic, retain) User *user;
@end

@interface Inspection (CoreDataGeneratedAccessors)

- (void)addFormAnswersObject:(FormAnswer *)value;
- (void)removeFormAnswersObject:(FormAnswer *)value;
- (void)addFormAnswers:(NSSet *)values;
- (void)removeFormAnswers:(NSSet *)values;

- (void)addFormQuestionsObject:(FormQuestion *)value;
- (void)removeFormQuestionsObject:(FormQuestion *)value;
- (void)addFormQuestions:(NSSet *)values;
- (void)removeFormQuestions:(NSSet *)values;

@end
