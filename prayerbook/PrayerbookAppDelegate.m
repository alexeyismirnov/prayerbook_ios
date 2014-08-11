//
//  PrayerbookAppDelegate.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "PrayerbookAppDelegate.h"
#import "MyLanguage.h"

@implementation PrayerbookAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int fontSize = [prefs integerForKey:@"fontSize"];
    
    if (fontSize == 0) {
        NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
 
        if ([lang  isEqual: @"zh-Hans"] || [lang  isEqual: @"zh-Hant"])
            [prefs setObject:@"cn" forKey:@"language"];
        else
            [prefs setObject:@"en" forKey:@"language"];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            [prefs setInteger:14 forKey:@"fontSize"];
        else
            [prefs setInteger:20 forKey:@"fontSize"];
        
        [prefs synchronize];
    }
    
    NSString *language = [prefs objectForKey:@"language"];
    [MyLanguage setLanguage:language];
    
    return YES;
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
