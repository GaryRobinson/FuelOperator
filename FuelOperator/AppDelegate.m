//
//  AppDelegate.m
//  FuelOperator
//
//  Created by Gary Robinson on 2/26/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

#define DATA_MODEL_VERSION @"1.4"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    [NewRelicAgent startWithApplicationToken:@"AAbd035cf0253ae2e54c3e0fa9e417ed3e7eb00b02"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self initMagicalRecord];
    
    //background fetch every 12 hours
    [application setMinimumBackgroundFetchInterval:[NSDate secondsPerDay]/2];
    
    [self applyStyle];
    [self setupLoginScreen];
    
    //[self.window makeKeyAndVisible];
    
    return YES;
}

- (void)initMagicalRecord
{
    // if a number I define or the build number changes, delete the core data db
    
    NSString *storeFileName = @"FuelOperator.sqllite";
    NSString *dataModelKey = @"OrcaDataModelVersion";
    NSString *buildNumberKey = @"BuildNumber";
    NSString *prevDataModelVersion = [[NSUserDefaults standardUserDefaults] objectForKey:dataModelKey];
    NSString *prevBuildNumber = [[NSUserDefaults standardUserDefaults] objectForKey:buildNumberKey];
    NSString *curBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    if(!prevDataModelVersion || ![prevDataModelVersion isEqualToString:DATA_MODEL_VERSION] ||
       !prevBuildNumber || ![prevBuildNumber isEqualToString:curBuildNumber])
    {
        //if this data model version is higher than the one that we store in NSUserDefaults
        //we need to "migrate" the database by clearing its data and re-syncing with the api
        NSURL *docsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        NSError *error;
        NSURL *dbURL = [docsURL URLByAppendingPathComponent:storeFileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:[dbURL path]])
            [[NSFileManager defaultManager] removeItemAtURL:dbURL error:&error];
        
        NSString *walName = [storeFileName stringByAppendingString:@"-wal"];
        NSURL *walURL = [docsURL URLByAppendingPathComponent:walName];
        if([[NSFileManager defaultManager] fileExistsAtPath:[walURL path]])
            [[NSFileManager defaultManager] removeItemAtURL:walURL error:&error];
        
        NSString *shmName = [storeFileName stringByAppendingString:@"-shm"];
        NSURL *shmURL = [docsURL URLByAppendingPathComponent:shmName];
        if([[NSFileManager defaultManager] fileExistsAtPath:[shmURL path]])
            [[NSFileManager defaultManager] removeItemAtURL:shmURL error:&error];
        
        //so, we'll need to delete the sync tokens as well
        //[SyncViewModel clearSyncTokens];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:DATA_MODEL_VERSION forKey:dataModelKey];
    [[NSUserDefaults standardUserDefaults] setObject:curBuildNumber forKey:buildNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:storeFileName];
    
}

- (void)setupLoginScreen
{
    LoginViewController *loginController = [[LoginViewController alloc] init];
	self.window.rootViewController = loginController;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        self.window.tintColor = [UIColor whiteColor];
	
	[self.window makeKeyAndVisible];
}

- (void)loginCompleted:(id)sender
{
    self.window.rootViewController = self.rootViewController;
}

- (void)logout:(id)sender
{
    [User logout];
    [self setupLoginScreen];
}

-(RootContainerViewController *)rootViewController
{
    if(_rootViewController == nil)
    {
        _rootViewController = [[RootContainerViewController alloc] init];
    }
    return _rootViewController;
}


- (void)applyStyle
{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
	[navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor fopDarkGreyColor]] forBarMetrics:UIBarMetricsDefault];
	[navigationBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:
										   [UIFont regularFontOfSize:6.0f], UITextAttributeFont,
										   [UIColor clearColor], UITextAttributeTextShadowColor,
										   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
										   [UIColor whiteColor], UITextAttributeTextColor,
										   nil]];
    
//    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
//    UIImage *image = [UIImage imageNamed:@"btn-back"];
//    UIImage *image = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)];
//    [barButtonItem setBackButtonBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [[UITextField appearance] setTintColor:[UIColor blackColor]];
        [[UITextView appearance] setTintColor:[UIColor blackColor]];
    }
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundLoginCompleted:) name:@"loginDone" object:nil];
    self.backgroundFetchCompletionHandler = completionHandler;
    [[OnlineService sharedService] attempBackgroundLogin];
}

- (void)backgroundLoginCompleted:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:@"inspectionsUpdated" object:nil];
    [[OnlineService sharedService] updateInspections];
}

- (void)dataUpdated:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"inspectionsUpdated" object:nil];
    self.backgroundFetchCompletionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // add a pause flag to inspection submission process
    [[OnlineService sharedService] pauseSubmission];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //?? save inspection submission and restore it on startup? How to handle login in that case?
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // remove pause flag from inspection submission process
    [[OnlineService sharedService] restartSubmission];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}


@end
