//
//  HttpManager.h
//  FuelOperator
//
//  Created by Gary Robinson on 3/7/15.
//  Copyright (c) 2015 GaryRobinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@interface HttpManager : AFHTTPRequestOperationManager



@end


@interface FOResponseSerializer : AFJSONResponseSerializer
@end

@interface FORequestSerializer : AFJSONRequestSerializer

@end