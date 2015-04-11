//
//  FormQuestion.h
//  FuelOperator
//
//  Created by Gary Robinson on 4/9/15.
//  Copyright (c) 2015 GaryRobinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FormAnswer, Inspection;

@interface FormQuestion : NSManagedObject

@property (nonatomic, retain) NSNumber * answerRequired;
@property (nonatomic, retain) NSString * componentID;
@property (nonatomic, retain) NSNumber * forceComment;
@property (nonatomic, retain) NSNumber * groupID;
@property (nonatomic, retain) NSNumber * imageRequired;
@property (nonatomic, retain) NSString * mainCategory;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSString * questionID;
@property (nonatomic, retain) NSNumber * recordID;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * subCategory;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * answerType;
@property (nonatomic, retain) FormAnswer *formAnswer;
@property (nonatomic, retain) Inspection *inspection;

@end
