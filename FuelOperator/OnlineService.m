//
//  OnlineService.m
//  FuelOperator
//
//  Created by Gary Robinson on 8/17/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "OnlineService.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "HttpManager.h"
#import "FormAnswer+Additions.h"

#define DEFAULT_NUM_WEEKS 4



@interface OnlineService ()

//@property (nonatomic, strong) AFHTTPClient *httpClient;

@property (nonatomic) NSInteger numProcessingInspections;
@property (nonatomic, strong) NSMutableArray *processingInspections;
@property (nonatomic, strong) NSMutableArray *processingAnswers;
@property (nonatomic, strong) NSMutableArray *processingPhotos;

@property (nonatomic, strong) Inspection *postingInspection;
@property (nonatomic) BOOL pauseSubmit;
@property (nonatomic) NSInteger postAnswerIndex;
@property (nonatomic, strong) UIImage *signatureImage;

@end

@implementation OnlineService

static OnlineService *sharedOnlineService = nil;

+(OnlineService *)sharedService
{
    if(sharedOnlineService == nil)
    {
        sharedOnlineService = [[super allocWithZone:nil] init];
        
    }
    return sharedOnlineService;
}


- (void)attemptLogin:(NSString *)username password:(NSString *)password baseURL:(NSString *)baseURL
{
    //?? for now, just let me login hard-coded
//    [self updateFacilities];
    [self loginDone:YES tryOffline:NO];
    
    
//    if(baseURL == nil)
//        baseURL = kBaseURLString;
//    
//    [HttpManager manager] = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
//    [[HttpManager manager] setParameterEncoding:AFFormURLParameterEncoding];
//    
//    
//    NSDictionary *params = @{@"userName" : username,
//                             @"password" : password,
//                             @"grant_type" : @"password"};
//    
//    NSString *path = @"Token";
//    [[HttpManager manager] postPath:path parameters:params
//                      success:^(AFHTTPRequestOperation *operation, id responseObject)
//    {
//        NSError *error;
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
//        self.token = [result objectForKey:@"access_token"];
//        NSString* auth = [NSString stringWithFormat:@"Bearer %@", self.token];
//        [[HttpManager manager] setDefaultHeader:@"Authorization" value:auth];
//        
//        User *user = [User MR_findFirstByAttribute:@"login" withValue:username];
//        if(!user)
//        {
//            user = [User MR_createEntity];
//            user.login = username;
//            user.password = [NSString encrypt:password];
//        }
//        [User login:user];
//        
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//        [self updateFacilities];
//        
//        //?? also update the requiredTypes
//        
//    }
//                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
//    {
//        [self loginDone:NO tryOffline:YES];
//    }];
    
}

- (void)attempBackgroundLogin
{
//    NSString *previousLoginName = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousLogin"];
//    User *previousUser = [User MR_findFirstByAttribute:@"login" withValue:previousLoginName];
//    if(!previousUser)
//        return;
//        
//    NSString *decryptedPassword = [NSString decrypt:previousUser.password];
//    [self attemptLogin:previousUser.login password:decryptedPassword baseURL:kBaseURLString];
}

- (void)updateFacilities
{
    NSDictionary *params = @{@"page_size" : @(10000)};
    NSString *path = @"facilities/";
    [[HttpManager manager] GET:path parameters:params
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *results = responseObject;
         for(NSDictionary *dict in results)
             [Facility updateOrCreateFromDictionary:dict];
         
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
         [self loginDone:YES tryOffline:NO];
     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //?? need to end the login process gracefully
         NSLog(@"failed updateFacilities");
         [self loginDone:NO tryOffline:NO];
     }
     ];
}

- (void)loginDone:(BOOL)success tryOffline:(BOOL)offline
{
    if(!success)
        [User logout];
    
    NSDictionary *userInfo = @{@"Success" : @(success),
                               @"TryOffline" : @(offline)};//[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:@"Success"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil userInfo:userInfo];
}

- (void)updateInspections
{
    //do the update from the server here
    NSDate *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"];
    if(start == nil)
    {
        start = [NSDate startOfTheWeekFromToday];
        [[NSUserDefaults standardUserDefaults] setObject:start forKey:@"startDate"];
    }
    NSDate *end = [[NSUserDefaults standardUserDefaults] objectForKey:@"endDate"];
    if(end == nil)
    {
        end = [NSDate dateWithNumberOfDays:DEFAULT_NUM_WEEKS*7 sinceDate:start];
        [[NSUserDefaults standardUserDefaults] setObject:end forKey:@"endDate"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateInspectionsFromDate:start toDate:end];
}

- (void)updateInspectionsFromDate:(NSDate *)dateFrom toDate:(NSDate *)dateTo
{
    [SVProgressHUD showWithStatus:@"Updating Inspections"];
    
    NSDictionary *params;
    [[HttpManager manager] GET:@"inspections" parameters:params
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *results = responseObject;
         
         [SVProgressHUD showProgress:0 status:@"Updating Inspections"];
         
         self.processingInspections = [[NSMutableArray alloc] init];
         for(NSDictionary *dict in results)
         {
             Inspection *inspection = [Inspection updateOrCreateFromDictionary:dict];
             [self.processingInspections addObject:inspection];
         }
         
         self.numProcessingInspections = self.processingInspections.count;

         //?? Download all the questions for each inspection also - i.e. start the inspection
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
         [self processNextInspection];
     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [SVProgressHUD dismiss];
         NSLog(@"failed get inspections");
         
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"inspectionsUpdated" object:nil];
         
     }];
}



- (void)processNextInspection
{
    if(self.processingInspections.count == 0)
    {
        [SVProgressHUD dismiss];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"inspectionsUpdated" object:nil];
        return;
    }
    
    float progress = (float)(self.numProcessingInspections - self.processingInspections.count) / (float)(self.numProcessingInspections);
    [SVProgressHUD showProgress:progress status:@"Updating Inspections"];
    
    Inspection *inspection = [self.processingInspections objectAtIndex:0];
    {
        //?? hmm, can I batch these requests?
        [self getFacilityForInspection:inspection];
    }
}

- (void)getFacilityForInspection:(Inspection *)inspection
{
    //hit the endpoint, make the facility, connect the inspection to it
    NSString *path = [NSString stringWithFormat:@"facilities/%d/", [inspection.facilityID intValue]];
    [[HttpManager manager] GET:path parameters:nil
                       success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //?? change this to save the facility
         
         NSDictionary *result = responseObject;
         Facility *f = [Facility updateOrCreateFromDictionary:result];
         inspection.facility = f;
 
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
         
         //success block
         if([inspection.inspectionID integerValue] == 0)
             [self startInspection:inspection];
         else
             [self getQuestionsForInspection:inspection];
         
     }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"failed get facility for inspection %d", [inspection.inspectionID intValue]);
         
         if(self.processingInspections.count > 0)
             [self.processingInspections removeObjectAtIndex:0];
         [self processNextInspection];
     }
     ];
    
    
    
}

- (void)startInspection:(Inspection *)inspection
{
    NSString *path = [NSString stringWithFormat:@"inspections/start/%d/start/", [inspection.inspectionID intValue]];
    [[HttpManager manager] POST:path parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //?? this probably isn't going to work yet
         NSError *error;
         NSDictionary *results = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
         
         inspection.inspectionID = [results objectForKey:@"InspectionID"];
         
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

         [self getQuestionsForInspection:inspection];
     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"failed startInspection");
     }
     ];
}

- (void)getQuestionsForInspection:(Inspection *)inspection
{
    //?? only re-download the questions if I don't already have them - this will miss any changes on the server, but who cares
    if(inspection.formQuestions.count > 0)
    {
        if(self.processingInspections.count > 0)
            [self.processingInspections removeObjectAtIndex:0];
        [self processNextInspection];
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"inspections/%d/questions/", [inspection.inspectionID intValue]];
    [[HttpManager manager] GET:path parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *results = responseObject;
         for(NSDictionary *questionDict in results)
         {
             [FormQuestion updateOrCreateFromDictionary:questionDict andInspection:inspection];
         }
         
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
         
         [self getAnswersForInspection:inspection];
    }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"failed get all questions for inspection %d", [inspection.inspectionID intValue]);
         
         if(self.processingInspections.count > 0)
             [self.processingInspections removeObjectAtIndex:0];
         [self processNextInspection];
     }
     ];
}

- (void)getAnswersForInspection:(Inspection *)inspection
{
    NSString *path = [NSString stringWithFormat:@"inspections/%d/answers/", [inspection.inspectionID intValue]];
    [[HttpManager manager] GET:path parameters:nil
                       success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *results = responseObject;
         for(NSDictionary *answerDict in results)
         {
             [FormAnswer updateOrCreateFromDictionary:answerDict andInspection:inspection];
         }
         
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
         
         if(self.processingInspections.count > 0)
             [self.processingInspections removeObjectAtIndex:0];
         [self processNextInspection];
     }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"failed get all questions for inspection %d", [inspection.inspectionID intValue]);
         
         if(self.processingInspections.count > 0)
             [self.processingInspections removeObjectAtIndex:0];
         [self processNextInspection];
     }
     ];
}

- (void)getUpdatedAnswers:(NSArray *)answers
{
    for(NSUInteger i=0; i<answers.count; i++)
    {
        FormAnswer *answer = (FormAnswer *)[answers objectAtIndex:i];
        
        NSString *path = [NSString stringWithFormat:@"api/question/answer/%d/", [answer.formQuestion.questionID intValue]];
        [[HttpManager manager] GET:path parameters:nil
                         success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSError *error;
             NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
             
             [answer updateFromDictionary:result];
             
             if(i == (answers.count - 1))
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"answersUpdated" object:nil];
         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if(i == (answers.count - 1))
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"answersUpdated" object:nil];
         }
         ];
    }
}


- (void)submitInspection:(Inspection *)inspection  withSignatureImage:(UIImage *)image;
{
    self.postingInspection = inspection;
    self.pauseSubmit = NO;
    self.postAnswerIndex = 0;
    self.signatureImage = image;
    
    [SVProgressHUD showProgress:0 status:@"Submitting..."];
    
    [self postNextAnswer];
}

- (void)pauseSubmission
{
    if(self.postingInspection)
        self.pauseSubmit = YES;
}

- (void)restartSubmission
{
    if(self.postingInspection)
    {
        self.pauseSubmit = NO;
        [self postNextAnswer];
    }
}

- (void)postNextAnswer
{
    if(self.pauseSubmit)
        return;
    
    FormQuestion *question = [[self.postingInspection.formQuestions allObjects] objectAtIndex:self.postAnswerIndex];
    
    if([question.formAnswer.submittted boolValue])
    {
        [self answerDone];
    }
    else
    {
        NSString *put = [NSString stringWithFormat:@"inspections/%d/questions/%d/",
                          [self.postingInspection.inspectionID intValue],
                          [question.recordID intValue]];
        
        NSDictionary *params;
    
        NSNumber *repairedOnSite = @(NO);
        if([question.formAnswer.repairedOnSite intValue] == 1)
            repairedOnSite = @(YES);
        
        if([question isDate])
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            NSString *strDate = [formatter stringFromDate:question.formAnswer.dateAnswer];
            
            params = @{@"answer" : strDate,
                       @"repaired_on_site" : repairedOnSite,
                       @"comment" : [question.formAnswer commentText],
                       @"component_id" : @"None",
                       @"component_id_field_name" : [NSNull null]};
        }
        else if([question isUserEntered])
        {
            params = @{@"answer" : @"1",
                       @"repaired_on_site" : repairedOnSite,
                       @"comment" : [question.formAnswer commentText],
                       @"component_id" : @"None",
                       @"component_id_field_name" : [NSNull null]};
        }
        else
        {
        
            NSNumber *answer = @(NO);
            if([question.formAnswer.answer intValue] == 1)
                answer = @(YES);
            
            params = @{  @"answer" : answer,
                         @"repaired_on_site" : repairedOnSite,
                         @"comment" : [question.formAnswer commentText],
                         @"component_id" : @"None",
                         @"component_id_field_name" : [NSNull null]};
        }
        
        [[HttpManager manager] PUT:put parameters:params success: ^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self uploadPhotosForAnswer:question.formAnswer];
            
        } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self answerDone];
        }];
    }
    
    
}

- (void)postAnswer:(FormAnswer *)answer
{
    
    NSString *put = [NSString stringWithFormat:@"inspections/%d/questions/%d/",
                      [answer.inspection.inspectionID intValue],
                      [answer.formQuestion.recordID intValue]];
    
    NSDictionary *params;
    
    NSNumber *repairedOnSite = @(NO);
    if([answer.repairedOnSite intValue] == 1)
        repairedOnSite = @(YES);
    
    if([answer.formQuestion isDate])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSString *strDate = [formatter stringFromDate:answer.dateAnswer];
        
        params = @{@"answer" : strDate,
                   @"repaired_on_site" : repairedOnSite,
                   @"comment" : [answer commentText],
                   @"component_id" : @"None",
                   @"component_id_field_name" : [NSNull null]};
    }
    else if([answer.formQuestion isUserEntered])
    {
        params = @{@"answer" : @"1",
                   @"repaired_on_site" : repairedOnSite,
                   @"comment" : [answer commentText],
                   @"component_id" : @"None",
                   @"component_id_field_name" : [NSNull null]};
    }
    else
    {
        NSNumber *value = @(NO);
        if([answer.answer intValue] == 1)
            value = @(YES);
        
        params = @{@"answer" : value,
                   @"repaired_on_site" : repairedOnSite,
                   @"comment" : [answer commentText],
                   @"component_id" : @"None",
                   @"component_id_field_name" : [NSNull null]};
    }
    
    
    [[HttpManager manager] PUT:put parameters:params success: ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self uploadPhotosForAnswer:answer];
        
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        answer.submittted = @(NO);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }];
}

- (void)uploadPhotosForAnswer:(FormAnswer *)answer
{
    if(answer.photos.count == 0)
    {
        answer.submittted = @(YES);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return;
    }
    
    NSArray *photos = [answer.photos allObjects];
    for(Photo *p in photos)
    {
        if(![p.uploaded boolValue])
            [self uploadPhoto:p];
    }
    
}

- (void)uploadPhoto:(Photo *)photo
{
    NSError *err;
    NSString *post = [NSString stringWithFormat:@"%@inspections/%d/attachments/", [[HttpManager manager].baseURL absoluteString], [photo.formAnswer.inspection.inspectionID intValue]];
    
    NSDictionary *params = @{@"type" : @"1",   //"General",
                             @"question" : photo.formAnswer.formQuestion.recordID,
                             @"inspection" : photo.formAnswer.inspection.inspectionID};
    NSURLRequest *request = [[HttpManager manager].requestSerializer multipartFormRequestWithMethod:@"POST" URLString:post parameters:params
                                                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                              
                                                                              [formData appendPartWithFileData:photo.jpgData name:@"file" fileName:@"photofile.png" mimeType:@"image/jpeg"];
                                                                              
                                                                          } error:&err];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[HttpManager manager].responseSerializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        photo.uploaded = @(YES);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        NSArray *photos = [photo.formAnswer.photos allObjects];
        BOOL done = YES;
        for(Photo *p in photos)
        {
            if(![p.uploaded boolValue])
            {
                done = NO;
                [self uploadPhoto:p];
            }
        }
        if(done)
        {
            photo.formAnswer.submittted = @(YES);
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            if(self.postingInspection)
                [self answerDone];
        }
	       
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"");
    }];
    [operation start];
}

- (void)saveDeficiency
{
//    FormQuestion *question = [[self.postingInspection.formQuestions allObjects] objectAtIndex:self.postAnswerIndex];
//    if([question.formAnswer.answer integerValue] != kNO)
//    {
//        [self uploadAnswerPhoto:0];
//        return;
//    }
//    
//    NSString *path = [NSString stringWithFormat:@"api/deficiency/save"];
//    
//    NSNumber *repaired = question.formAnswer.repairedOnSite;
//    if(!repaired)
//        repaired = [NSNumber numberWithBool:NO];
//    
//    NSDictionary *params = @{  @"InspectionID" : self.postingInspection.inspectionID,
//                               @"QuestionID" : question.questionID,
//                               @"Comments" : [question.formAnswer commentText],
//                               @"RepairedOnSite" : repaired }; //?? actually hook this up to UI
//    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
//    NSMutableData *body = [NSMutableData data];
//    [body appendData:jsonData];
//    
//    
//    NSMutableURLRequest *request = [[HttpManager manager] requestWithMethod:@"POST" path:path parameters:nil/*params*/];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:body];
//    
//    [[HttpManager manager] registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         [self uploadAnswerPhoto:0];
//         
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         NSLog(@"failed post deficiency to questionID: %d", [question.questionID intValue]);
//         [self answerDone];
//     }];
//    
//    [operation start];
}

- (void)uploadAnswerPhoto:(NSInteger)index
{
//    FormQuestion *question = [[self.postingInspection.formQuestions allObjects] objectAtIndex:self.postAnswerIndex];
//    if(!question.formAnswer.photos)
//    {
//        [self answerDone];
//        return;
//    }
//    if(index >= question.formAnswer.photos.count)
//    {
//        [self answerDone];
//        return;
//    }
//    
//    Photo *photo = [[question.formAnswer.photos allObjects] objectAtIndex:index];
//    if([photo.uploaded boolValue])
//    {
//        [self uploadAnswerPhoto:index+1];
//        return;
//    }
//    
//    NSString *path = [NSString stringWithFormat:@"api/question/attachimage/%d/%d", [question.inspection.inspectionID intValue], [question.questionID intValue]];
//    if([question.formAnswer.answer integerValue] == kNO)
//        path = [NSString stringWithFormat:@"api/deficiency/attachimage/%d/%d", [question.inspection.inspectionID intValue], [question.questionID intValue]];
//    
//    NSMutableURLRequest *request;
//    request = [[HttpManager manager] multipartFormRequestWithMethod:@"POST" path:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
//               {
//                   [formData appendPartWithFileData:photo.jpgData name:@"photo" fileName:@"photofile.jpg" mimeType:@"image/jpeg"];
//               }];
//    
//    
//    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success Block Hit!, %@", responseObject);
//        photo.uploaded = [NSNumber numberWithBool:YES];
//        [self uploadAnswerPhoto:index+1];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failed to upload photo");
//        [self answerDone];
//    }];
//    
//    [operation start];
}

- (void)answerDone
{
    [SVProgressHUD showProgress:((float)self.postAnswerIndex / (float)self.postingInspection.formQuestions.count) status:@"Submitting..."];
    self.postAnswerIndex++;
    
    if(self.postAnswerIndex < self.postingInspection.formQuestions.count)
        [self postNextAnswer];
    else
        [self saveSignatureImage];
}

- (void)saveSignatureImage
{
    NSError *err;
    NSString *post = [NSString stringWithFormat:@"%@inspections/%d/attachments/", [[HttpManager manager].baseURL absoluteString], [self.postingInspection.inspectionID intValue]];
    
    NSDictionary *params = @{@"type" : @"4", // "Signature",
                             @"inspection" : self.postingInspection.inspectionID};
    NSURLRequest *request = [[HttpManager manager].requestSerializer multipartFormRequestWithMethod:@"POST" URLString:post parameters:params
                                                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                              
                                                                              [formData appendPartWithFileData:UIImageJPEGRepresentation(self.signatureImage, 1.0) name:@"file" fileName:@"photofile.png" mimeType:@"image/jpeg"];
                                                                              
                                                                          } error:&err];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[HttpManager manager].responseSerializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self closeInspection];
	       
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"failed signature image");
        [self closeInspection];
    }];
    [operation start];
}

- (void)closeInspection
{
    //?? still do the signature?
    
    NSDictionary *params = @{@"scheduled" : [NSNull null],
                             @"start" : [NSNull null],
                             @"stop" : [NSNull null]};
    params = nil;
    NSString *post = [NSString stringWithFormat:@"inspections/%d/stop/", [self.postingInspection.inspectionID intValue]];
    [[HttpManager manager] PUT:post parameters:params success: ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.postingInspection.submitted = [NSNumber numberWithBool:YES];
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        self.postingInspection = nil;
         [SVProgressHUD dismiss];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"inspectionSubmitted" object:nil];
        
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        self.postingInspection.submitted = [NSNumber numberWithBool:NO];
         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        self.postingInspection = nil;
         [SVProgressHUD showImage:nil status:@"Failed to submit inspection"];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"inspectionSubmitted" object:nil];
    }];
    
}






@end
