//
//  CustomNavigationController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/7/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "CustomNavigationController.h"
#import "HomeViewController.h"
#import "CheckoutViewController.h"
#import "ServiceLogic.h"
#import "ApplicationHelper.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[ServiceLogic getObject] getVersionNumberWithCompleteionBlock:^(id response) {
//        NSDictionary *responseDictionary = [NSJSONSerialization
//                                            JSONObjectWithData:response
//                                            options:NSJSONReadingMutableLeaves
//                                            error:nil];
//
//        if (![[ApplicationHelper getApplicationVersion] isEqualToString:[responseDictionary objectForKey:@"ios_app_version"]]) {
//            
//            UIAlertController *outOfDateAlert = [UIAlertController alertControllerWithTitle:@"Out of date version" message:@"You have to update your version" preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction *updateVersionAction = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/easy-as-pie/id1228315221?mt=8"] options:@{} completionHandler:nil];
//            }];
//            
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                exit(0);
//            }];
//            
//            [outOfDateAlert addAction:updateVersionAction];
//            [outOfDateAlert addAction:cancelAction];
//            
//            [self presentViewController:outOfDateAlert animated:YES completion:nil];
//        } else {
            NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
            if (userToken && [userToken length]>0) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                HomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
                [self setViewControllers:@[homeVc]];
            }
//        }
        

    
    
   
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"checkout"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(checkout)];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    
    
}
-(void)checkout{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    CheckoutViewController *checkoutVc = [storyboard instantiateViewControllerWithIdentifier:@"checkoutVC"];
    [self.navigationController pushViewController:checkoutVc animated:YES];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
