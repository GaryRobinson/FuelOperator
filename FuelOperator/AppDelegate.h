//
//  AppDelegate.h
//  FuelOperator
//
//  Created by Gary Robinson on 2/26/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootContainerViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) RootContainerViewController *rootViewController;
@property (copy) void (^backgroundFetchCompletionHandler)();


- (void)loginCompleted:(id)sender;
- (void)logout:(id)sender;

@end
