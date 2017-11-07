//
//  LoginViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/7/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "InitialViewController.h"
#import "UIHelper.h"
#import "HomeViewController.h"
@interface InitialViewController ()
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitialViewState];
   
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Helper methods
-(void)setupInitialViewState{
    self.skipButton.layer.borderWidth = 1.0;
    self.skipButton.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    self.skipButton.layer.cornerRadius = 2.0;
    self.skipButton.layer.masksToBounds = YES;
    
    self.loginButton.layer.borderWidth = 1.0;
    self.loginButton.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    self.loginButton.layer.cornerRadius = 2.0;
    self.loginButton.layer.masksToBounds = YES;
    
    self.createAccountButton.layer.borderWidth = 1.0;
    self.createAccountButton.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    self.createAccountButton.layer.cornerRadius = 2.0;
    self.createAccountButton.layer.masksToBounds = YES;
}
#pragma mark - skip button action
- (IBAction)skipButtonAction:(id)sender {
 
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    HomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
    [self.navigationController setViewControllers:@[homeVc]];
    
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
