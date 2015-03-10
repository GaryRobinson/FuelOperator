//
//  OnlineService.h
//  FuelOperator
//
//  Created by Gary Robinson on 8/17/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Inspection.h"

@interface OnlineService : NSObject

+(OnlineService *)sharedService;

@property (nonatomic, strong, readonly) NSString *sessionGuid;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *baseURL;

- (void)attemptLogin:(NSString *)username password:(NSString *)password baseURL:(NSString *)baseURL;
- (void)attempBackgroundLogin;

- (void)updateFacilities;
- (void)updateInspections;//FromDate:(NSDate *)dateFrom toDate:(NSDate *)dateTo;
- (void)startInspection:(Inspection *)inspection;
- (void)getQuestionsForInspection:(Inspection *)inspection;
- (void)getAnswersForInspection:(Inspection *)inspection;
- (void)getUpdatedAnswers:(NSArray *)answers;


- (void)submitInspection:(Inspection *)inspection withSignatureImage:(UIImage *)image;
- (void)pauseSubmission;
- (void)restartSubmission;

@end
