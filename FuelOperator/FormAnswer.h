//
//  FormAnswer.h
//  FuelOperator
//
//  Created by Gary Robinson on 4/11/15.
//  Copyright (c) 2015 GaryRobinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FormQuestion, Inspection, Photo;

@interface FormAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * answer;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * dateAnswer;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * recordID;
@property (nonatomic, retain) NSNumber * repairedOnSite;
@property (nonatomic, retain) NSNumber * submittted;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * userEnteredIndex;
@property (nonatomic, retain) FormQuestion *formQuestion;
@property (nonatomic, retain) Inspection *inspection;
@property (nonatomic, retain) NSSet *photos;
@end

@interface FormAnswer (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
