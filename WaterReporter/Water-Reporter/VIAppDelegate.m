//
//  VIAppDelegate.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VIAppDelegate.h"
#import "Lockbox.h"

#define COLOR_BRAND_BLUE_BASE [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0]
#define COLOR_BRAND_WHITE_BASE [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]

#define kWaterReporterUserAccessToken        @"kWaterReporterUserAccessToken"

@implementation VIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedPreviously"])
    {
        [Lockbox setString:@"" forKey:kWaterReporterUserAccessToken];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedPreviously"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // Change the NavigationController Toolbar and Status bar color to white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Setup our "My Location" Tab and ensure it's placed within the NavigationController
    VILocationViewController *locationViewController = [[VILocationViewController alloc] init];
    UINavigationController *locationNavigationController = [[UINavigationController alloc] initWithRootViewController:locationViewController];

    // Setup our "Submit Report" Tab and ensure it's placed within the NavigationController
    VIFormTableViewController *formViewController = [[VIFormTableViewController alloc] init];
    UINavigationController *formNavigationController = [[UINavigationController alloc] initWithRootViewController:formViewController];

    // Setup our "My Reports" Tab and ensure it's placed within the NavigationController
    VIReportsTableViewController *reportsViewController = [[VIReportsTableViewController alloc] init];
    UINavigationController *reportsNavigationController = [[UINavigationController alloc] initWithRootViewController:reportsViewController];
    
    // Define and popluate our Tab Bar with the content defined above
    UITabBarController *tabBarCtrl = [[UITabBarController alloc] init];
    [tabBarCtrl setViewControllers:@[locationNavigationController, formNavigationController, reportsNavigationController] animated:YES];

    // Set Toolbar/Statusbar to Green with White text throughout the entire application
	[[UINavigationBar appearance] setBarTintColor:COLOR_BRAND_BLUE_BASE];
    [[UINavigationBar appearance] setTintColor:COLOR_BRAND_WHITE_BASE];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : COLOR_BRAND_WHITE_BASE}];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarCtrl;
    [self.window makeKeyAndVisible];
    
    [self setupCoreData];

    return YES;
}

-(void)setupCoreData {

    NSString *storeFileName = [MagicalRecord defaultStoreName];

    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:storeFileName];

    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:storeFileName];

    NSError *error;
    
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
    
    if (![[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:[storeURL path] error:&error]) {
        NSLog(@"Data Protection Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self addSkipBackupAttributeToItemAtURL:storeURL];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
