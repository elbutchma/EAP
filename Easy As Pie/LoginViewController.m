//
//  LoginViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/9/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "LoginViewController.h"
#import "UIHelper.h"
#import "ShopifyManager.h"
#import "HomeViewController.h"
#import "MBProgressHUD.h"
@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitialView];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapper];
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceded:) name:@"login_token" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:@"login_token_error" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
-(void)hideKeyboard{
    [self.view endEditing:YES];
}


- (IBAction)loginButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if(![self validateEmail]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a valid email." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (![self validatePassword]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a valid password." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *items = @[[BUYAccountCredentialItem itemWithEmail:self.emailTextField.text], [BUYAccountCredentialItem itemWithPassword:self.passwordTextField.text]];
    BUYAccountCredentials *credentials = [BUYAccountCredentials credentialsWithItems:items];
    
    
    [ShopifyManager authenticateUser:credentials];
}


#pragma mark - helper methods

-(BOOL)validateEmail{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self.emailTextField.text];
}

-(BOOL)validatePassword{
    if ([self.passwordTextField.text length] < 5) {
        return NO;
    } else{
        return YES;
    }
}

-(void)setupInitialView{
    
    [self.navigationController.navigationBar setHidden:NO];
    
    self.emailTextField.layer.borderWidth = 1.0;
    self.emailTextField.layer.cornerRadius = 2.0;
//    self.emailTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.passwordTextField.layer.borderWidth = 1.0;
    self.passwordTextField.layer.cornerRadius = 2.0;
//    self.passwordTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.loginButton.layer.borderWidth = 1.0;
    self.loginButton.layer.cornerRadius = 2.0;
//    self.loginButton.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
}

#pragma mark - shopify methods
-(void)loginSucceded:(NSNotification*)notification{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    BUYCustomerToken *token = [notification.userInfo objectForKey:@"token"];
    
    BUYCustomer *customer = [notification.userInfo objectForKey:@"customer"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[customer JSONDictionary] forKey:@"customer"];
     [[NSUserDefaults standardUserDefaults] setObject:[customer.defaultAddress jsonDictionaryForCheckout] forKey:@"address"];

    [[NSUserDefaults standardUserDefaults] setObject:customer.identifier forKey:@"customerId"];
    [[NSUserDefaults standardUserDefaults] setObject:customer.email forKey:@"email"];

     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    HomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
    [self.navigationController setViewControllers:@[homeVc]];
    
    BUYCart *cart = nil;
    [[NSUserDefaults standardUserDefaults] setObject:cart forKey:@"cart"];
}

-(void)loginFailed:(NSNotification*)notification{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
    
    NSError *error = [notification.userInfo objectForKey:@"error"];
    NSString *errorMessage ;
    if ([error.userInfo objectForKey:@"error"]) {
        errorMessage = [error.userInfo objectForKey:@"error"];
    } else {
        errorMessage = [error localizedDescription];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - skip button action
- (IBAction)skipButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    HomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
    [self.navigationController setViewControllers:@[homeVc]];
    
}

#pragma mark - uitextfield delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    CGRect f = self.view.frame;
    f.origin.y = 0.0f;
    self.view.frame = f;
    [self.view endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height+100;
        self.view.frame = f;
    }];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect f = self.view.frame;
//        f.origin.y = 0.0f;
//        self.view.frame = f;
//    }];
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
