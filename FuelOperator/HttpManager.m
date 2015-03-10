//
//  HttpManager.m
//  FuelOperator
//
//  Created by Gary Robinson on 3/7/15.
//  Copyright (c) 2015 GaryRobinson. All rights reserved.
//

#import "HttpManager.h"

static NSString * const kBaseURLString = @"http://www.fueloperator.com/api/v1/";
static NSString * const myToken = @"5efd9a55bd3e1f3283fda359cf92191355d96a01";
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";


@implementation HttpManager

static HttpManager *sharedInstance = nil;

+ (instancetype)manager {
    if(sharedInstance == nil)
    {
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
    }
    return sharedInstance;
}

#pragma mark - initWithBaseURL

- (id)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) return nil;
    
    self.requestSerializer = [[FORequestSerializer alloc] init];
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:@"garyrobinson" password:myToken];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"ACCEPT"];
    
    self.responseSerializer = [[FOResponseSerializer alloc] init];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    return self;
}

@end




#pragma mark - FORequestSerializer

@implementation FORequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
//    request.timeoutInterval = self.timeoutInterval;
    
    return request;
}

@end

#pragma mark - FOResponseSerializer

@implementation FOResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    
    id responseObject = [super responseObjectForResponse:response data:data error:error];
    if (*error != nil) {
        NSLog(@"response serializer error: %@", [(*error).userInfo description]);
        return nil;
    }
    if([responseObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictionary = responseObject;
        return dictionary[@"results"];
    }
    else if([responseObject isKindOfClass:[NSArray class]])
        return responseObject;
    
    return nil;
}

@end