//
//  AppDelegate.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 2/24/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "AppDelegate.h"
#import <ZDCChat/ZDCChat.h>
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "CustomNavigationController.h"
#import "Firebase.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //initialize zendesk chat sdk
    [ZDCChat initializeWithAccountKey:@"1MxZHr1fUEgqxxi2LezIAlsVdSmV3RNi"];
    [[[ZDCChat instance] overlay] setEnabled:NO];
    [self configureSideMenu];
//    [FIRApp configure];
    return YES;
}

-(void)configureSideMenu{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    SideMenuViewController *sideMenu = [storyboard instantiateViewControllerWithIdentifier:@"SideMenuTableView"];
    
    CustomNavigationController *mainNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];

    
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:mainNavigationController
                                                    leftMenuViewController:sideMenu
                                                    rightMenuViewController:nil];
    
    //disable pan gesture
    container.panMode = MFSideMenuPanModeNone;
    
    // enable/disable the shadow
    [container.shadow setEnabled:YES];
    // set the radius of the shadow
    [container.shadow setRadius:10.0f];
    
    // set the color of the shadow
    [container.shadow setColor:[UIColor blackColor]];
    
    [container.leftMenuViewController setModalPresentationCapturesStatusBarAppearance:YES];
    
    container.leftMenuWidth = (7*[UIScreen mainScreen].bounds.size.width)/9;
    
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
