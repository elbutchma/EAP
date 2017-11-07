//
//  ChechoutsuccessViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 8/19/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "CheckoutsuccessViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <ZDCChat/ZDCChat.h>
#import "ShopifyManager.h"

@interface CheckoutsuccessViewController ()

@end

@implementation CheckoutsuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Checkout";
    self.navigationItem.backBarButtonItem.title = @"Back";
    [self.navigationItem.backBarButtonItem setTarget:self];
    [self.navigationItem.backBarButtonItem setAction:@selector(backButtonAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)callUsButtonAction:(UIButton *)sender {
//    [self.navigationController popToRootViewControllerAnimated:YES];
    NSString *phoneNumber = @"+201200912397";
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];

    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]];
    
    if([[UIApplication sharedApplication]canOpenURL:url]&&carrier!=nil&&carrier.isoCountryCode){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (IBAction)liveChatButtonAction:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSDictionary *customerDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"customer"];
    __block BUYCustomer *customer = [[[[ShopifyManager sharedInstance] buyClient] modelManager] insertCustomerWithJSONDictionary:customerDic];
    
    
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *user) {
        user.phone = customer.defaultAddress.phone;
        user.name = [NSString stringWithFormat:@"%@ %@", customer.firstName, customer.lastName];
        user.email = customer.email;
    }];
    
    [ZDCChat startChat:^(ZDCConfig *config) {
   
        config.emailTranscriptAction = ZDCEmailTranscriptActionNeverSend;
    }];

}


- (void)backButtonAction:(id)sender {
    // pop to root view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
