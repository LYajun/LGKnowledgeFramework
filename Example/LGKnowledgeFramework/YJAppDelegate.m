//
//  YJAppDelegate.m
//  LGKnowledgeFramework
//
//  Created by lyj on 09/18/2019.
//  Copyright (c) 2019 lyj. All rights reserved.
//

#import "YJAppDelegate.h"
#import <YJTaskMark/YJSpeechManager.h>
#import <YJNetManager/YJNetMonitoring.h>
@implementation YJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[YJNetMonitoring shareMonitoring] startNetMonitoring];
    [[YJSpeechManager defaultManager] initEngine];
    
    
    [[YJNetMonitoring shareMonitoring] checkNetCanUseWithComplete:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (![YJSpeechManager defaultManager].isInitEngine) {
        [[YJSpeechManager defaultManager] initEngine];
    }
    if ([YJNetMonitoring shareMonitoring].networkCanUseState != 1) {
        [[YJNetMonitoring shareMonitoring] checkNetCanUseWithComplete:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}
//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    
////    if (self.allowRotation) {
//        return  UIInterfaceOrientationMaskAllButUpsideDown;
////    }
////    return UIInterfaceOrientationMaskPortrait;
//}
@end
