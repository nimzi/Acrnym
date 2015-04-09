//
//  AppDelegate.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/7/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "DataController.h"
#import "Acronym.h"
#import "LongForm.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


-(void) testDatabase {
  DataController* dc = [DataController instance];
//
//  [dc upsertAcromym:@"NASA"];
//  [dc saveContext];
  
  [dc logDebugDescription];
  
  
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.rootViewController = [ViewController new];
  [self.window makeKeyAndVisible];
  
  [self testDatabase];
  
  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  // Saves changes in the application's managed object context before the application terminates.
  [[DataController instance] saveContext];
}


@end
