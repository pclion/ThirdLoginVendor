//
//  AppDelegate.m
//  PCThirdLoginDemo
//
//  Created by 张培创 on 15/3/12.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import "AppDelegate.h"
#import "PCThirdUserManager.h"
#import <objc/runtime.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [PCThirdUserManager initializeSNSSdkWithWeixinAppId:@"wx5bc067c5c1073564" weixinSecret:@"773569756f5b73aca618e12866b0a5bc" weibo:@"2505657114" weiboRedirectUrl:@"http://sns.whalecloud.com/sina2/callback" qq:@"1103288905"];
    [self methodSwizzling];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) methodSwizzling
{
    Class c = objc_getClass("WeiboSDK3rdApp");
    id block = ^NSString*()
    {
        return @"com.duowan.rtquiz";
    };
    
    SEL selctor = NSSelectorFromString(@"bundleID");
    IMP test = imp_implementationWithBlock(block);
    Method origMethod = class_getInstanceMethod(c,
                                                selctor);
    
    if(!class_addMethod(c, selctor, test,
                        method_getTypeEncoding(origMethod)))
    {
        method_setImplementation(origMethod, test);
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[PCThirdUserManager defaultManager] handleOpenUrl:url];
}

@end
