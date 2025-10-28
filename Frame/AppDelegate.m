//
//  AppDelegate.m
//  Frame
//
//  Created by 冯汉栩 on 2021/2/7.
//

#import "AppDelegate.h"
#import "FHXTabBarController.h"
#import "BrowseViewController.h"
#import "HomeViewController.h"
#import "NewViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];

    FHXTabBarController *tabBarVC = [[FHXTabBarController alloc]init];
    [tabBarVC setUpOneChildViewController:[[BrowseViewController alloc] init] image:@"cart" selectedImage:@"cartOn" title:@"cart"];
    [tabBarVC setUpOneChildViewController:[[HomeViewController alloc] init] image:@"home" selectedImage:@"homeOn" title:@"home"];
    [tabBarVC setUpOneChildViewController:[[NewViewController alloc] init] image:@"class" selectedImage:@"classOn" title:@"class"];
    self.window.rootViewController = tabBarVC;
    
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - UISceneSession lifecycle

//
//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
