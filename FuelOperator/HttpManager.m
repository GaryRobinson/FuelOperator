//
//  HttpManager.m
//  FuelOperator
//
//  Created by Gary Robinson on 3/7/15.
//  Copyright (c) 2015 GaryRobinson. All rights reserved.
//

#import "HttpManager.h"

static NSString * const kBaseURLString = @"https://www.fueloperator.com/api/v1/";
static NSString * const myToken = @"20530f91ea0d42db2348911dec3e8a000a1b6e38";
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
    
//    self.responseSerializer = [[FOResponseSerializer alloc] init];
    self.responseSerializer = [FOResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", nil];
    
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
        if([responseObject isKindOfClass:[NSString class]])
            NSLog(@"response serializer error: %@", responseObject);
        else
            NSLog(@"response serializer error: %@", [(*error).userInfo description]);
        return nil;
    }
    if([responseObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictionary = responseObject;
        if(dictionary[@"results"])
            return dictionary[@"results"];
        else
            return dictionary;
    }
    else if([responseObject isKindOfClass:[NSArray class]])
        return responseObject;
    
    return nil;
}

@end