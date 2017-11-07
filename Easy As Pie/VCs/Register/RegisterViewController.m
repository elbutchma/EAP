//
//  RegisterViewController.m
//  Easy As Pie
//
//  Created by Mostafa Elbutch on 3/7/17.
//  Copyright © 2017 Mostafa Elbutch. All rights reserved.
//

#import "RegisterViewController.h"
#import "ShopifyManager.h"
#import "UIHelper.h"
#import "MBProgressHUD.h"
#import "ActionSheetPicker.h"
#import "HomeViewController.h"
#import "WorkContainerViewController.h"
#import "HomeContainerViewController.h"

@interface RegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *homeContainerView;
@property (weak, nonatomic) IBOutlet UIView *workContainerView;
//@property (weak, nonatomic) IBOutlet UITextField *workAreaTextField;
//@property (weak, nonatomic) IBOutlet UITextField *workCompanyNameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *workAddressTextField;
//@property (weak, nonatomic) IBOutlet UITextField *homeAddressTextField;
//@property (weak, nonatomic) IBOutlet UITextField *homeAreaTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIScrollView *firstScrollView;
@property (weak, nonatomic) IBOutlet UIView *secondScrollView;

@property (nonatomic, strong) NSArray *areasArray;

@property (nonatomic) BOOL isWork;
@property (nonatomic) BOOL isAddressAdded;
@property (nonatomic,strong) BUYCustomer *customer;
@property (nonatomic, strong) WorkContainerViewController *workVC;
@property (nonatomic, strong) HomeContainerViewController *homeVC;


@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:NO];
    
    
    UITapGestureRecognizer *tapper1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *tapper2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *tapper3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *tapper4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *tapper5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *tapper6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    UITapGestureRecognizer *tapper7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:tapper1];
    [self.firstView addGestureRecognizer:tapper2];
    [self.secondView addGestureRecognizer:tapper3];
    [self.homeContainerView addGestureRecognizer:tapper4];
    [self.workContainerView addGestureRecognizer:tapper5];
    [self.firstScrollView addGestureRecognizer:tapper6];
    [self.secondScrollView addGestureRecognizer:tapper7];
    
    self.isWork = YES;
    self.isAddressAdded = NO;
    
    if (self.isAddAddress) {
        [self.firstView setHidden:YES];
        [self.secondView setHidden:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSuccess:) name:@"registeration_success" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressAdded) name:@"address_added" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerfailed:) name:@"registeration_failed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressFailed) name:@"address_failed" object:nil];
    
    self.areasArray = @[@"Banks Center – Teseen St.", @"Companies Center – Teseen St.", @"Cairo Festival City", @"Downtown – Teseen St.", @"FUE", @"AUC", @"District 1 – 5th settlement", @"District 2 – 5th settlement", @"Ganoob El Acadimia A", @"Ganoob El Acadimia B", @"Ganoob El Acadimia C", @"Ganoob El Acadimia D", @"Ganoob El Acadimia E \"ه\"", @"Ganoob El Acadimia F\"و\"", @"Ganoob El Acadimia G\"ز\"", @"El Banafseg 11", @"El Banafseg 12", @"El Banafseg Apartment Buildings", @"El Narges 1", @"El Narges 2", @"El Narges 3", @"El Narges 4", @"El Shouyfat", @"El Yasmeen 6", @"El Yasmeen 7", @"Other"];
    [self setupInitialView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helper methods
-(void)setupInitialView{
    self.firstNameTextField.layer.borderWidth = 1.0;
    self.firstNameTextField.layer.cornerRadius = 2.0;
//    self.firstNameTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.lastNameTextField.layer.borderWidth = 1.0;
    self.lastNameTextField.layer.cornerRadius = 2.0;
//    self.lastNameTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.mobileTextField.layer.borderWidth = 1.0;
    self.mobileTextField.layer.cornerRadius = 2.0;
//    self.mobileTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.emailTextField.layer.borderWidth = 1.0;
    self.emailTextField.layer.cornerRadius = 2.0;
//    self.emailTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.passwordTextField.layer.borderWidth = 1.0;
    self.passwordTextField.layer.cornerRadius = 2.0;
//    self.passwordTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.nextButton.layer.borderWidth = 1.0;
    self.nextButton.layer.cornerRadius = 2.0;
//    self.nextButton.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.workVC.workAreaTextField.layer.borderWidth = 1.0;
    self.workVC.workAreaTextField.layer.cornerRadius = 2.0;
//    self.workVC.workAreaTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.workVC.workAddressTextField.layer.borderWidth = 1.0;
    self.workVC.workAddressTextField.layer.cornerRadius = 2.0;
//    self.workVC.workAddressTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.workVC.workCompanyNameTextField.layer.borderWidth = 1.0;
    self.workVC.workCompanyNameTextField.layer.cornerRadius = 2.0;
//    self.workVC.workCompanyNameTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    self.homeVC.homeAreaTextField.layer.borderWidth = 1.0;
    self.homeVC.homeAreaTextField.layer.cornerRadius = 2.0;
//    self.homeVC.homeAreaTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    
    
    self.homeVC.homeAddressTextField.layer.borderWidth = 1.0;
    self.homeVC.homeAddressTextField.layer.cornerRadius = 2.0;
//    self.homeVC.homeAddressTextField.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    
    self.registerButton.layer.borderWidth = 1.0;
    self.homeVC.homeAddressTextField.layer.cornerRadius = 2.0;
//    self.registerButton.layer.borderColor = [[UIHelper colorWithHexString:@"E9000D"] CGColor];
    
    if (self.isAddAddress) {
        [self.registerButton setTitle:@"Add Address" forState:UIControlStateNormal];
    }
    
    self.homeVC.homeAreaTextField.delegate = self;
    self.workVC.workAreaTextField.delegate = self;
    self.workVC.workAddressTextField.delegate = self;
    self.workVC.workCompanyNameTextField.delegate = self;
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.mobileTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
}

-(BOOL)validateEmail{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self.emailTextField.text];
}
#pragma mark - actions
-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (IBAction)nextButtonAction:(UIButton *)sender {
    
    
    
    
    if (self.firstNameTextField.text.length < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter your first name." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if (self.lastNameTextField.text.length < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter your last name." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if (self.passwordTextField.text.length < 6) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter at least 6 characters for password." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
    
    if (![self validateEmail]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a valid email." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] setObject:self.firstNameTextField.text forKey:@"firstName"];
        [[NSUserDefaults standardUserDefaults] setObject:self.lastNameTextField.text forKey:@"lastName"];
        [[NSUserDefaults standardUserDefaults] setObject:self.mobileTextField.text forKey:@"phone"];
        
        
        //////////
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSArray *items = @[[BUYAccountCredentialItem itemWithEmail:self.emailTextField.text], [BUYAccountCredentialItem itemWithFirstName:self.firstNameTextField.text], [BUYAccountCredentialItem itemWithLastName:self.lastNameTextField.text], [BUYAccountCredentialItem itemWithPassword:self.passwordTextField.text]];
        
        BUYAccountCredentials *credentials = [BUYAccountCredentials credentialsWithItems:items];
        
        [ShopifyManager registerUser:credentials];
        //////////////
        [self.firstView setHidden:YES];
        [self.secondView setHidden:NO];
        [self.pageControl setCurrentPage:2];
    }
}
- (IBAction)segmenControlValueChanged:(UISegmentedControl *)sender {
    
    
    if (sender.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:(0.7) animations:^{
            self.workContainerView.alpha = 1;
            self.homeContainerView.alpha = 0;
            self.isWork = YES;
            
            
        }];
    } else {
        [UIView animateWithDuration:(0.7) animations:^{
            self.workContainerView.alpha = 0;
            self.homeContainerView.alpha = 1;
            self.isWork = NO;
        }];
    }
}
- (IBAction)registerUserButtonAction:(UIButton *)sender {
    if (self.isWork && self.workVC.workAddressTextField.text.length < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter your address." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (self.isWork && self.workVC.workCompanyNameTextField.text.length < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter your company name." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (!self.isWork && self.homeVC.homeAddressTextField.text.length < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter your address." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if (!self.customer) {
            self.customer = [[[[ShopifyManager sharedInstance] buyClient] modelManager] insertCustomerWithJSONDictionary:(NSDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:@"customer"]];
        }
        
        BUYAddress *address = [[[ShopifyManager sharedInstance].buyClient modelManager] insertAddressWithJSONDictionary:nil];
        if (self.isWork) {
            address.address1 = self.workVC.workAddressTextField.text;
        } else{
            address.address1 = self.homeVC.homeAddressTextField.text;
        }
        
        
        address.city = @"CAIRO";
        address.province=@"cairo";
        address.zip=@"12021";
        
        address.country = @"Egypt";
        address.countryCode=@"Egypt";
        address.provinceCode = @"2";
        // NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"];
        //NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"];
        NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone"];
        address.phone = phone;
        address.firstName = self.customer.firstName ;
        address.lastName = self.customer.lastName;
        if (self.isWork)
            address.company = self.workVC.workCompanyNameTextField.text ;
        
        
//        [[NSUserDefaults standardUserDefaults] setObject:[address jsonDictionaryForCheckout] forKey:@"address"];
        
//        NSMutableSet *addressesSet = [self.customer addressesSet];
//        [addressesSet addObject:address];
//        
//        [self.customer setPrimitiveAddresses:addressesSet]
        [self.customer setDefaultAddress:address];
        

        [address setCustomer:self.customer];
        NSSet *set = self.customer.addresses;
        set = [set setByAddingObject:address];
        [self.customer setAddresses:set];
        [[NSUserDefaults standardUserDefaults] setObject:[self.customer JSONDictionary] forKey:@"customer"];
        [ShopifyManager createAdress:address];
    }
    
}

#pragma mark - shopify

-(void)registerSuccess:(NSNotification*)notification{
    
    
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    BUYCustomer *customer = [[notification userInfo] objectForKey:@"customer"];
    self.customer = customer;
    
    
    //    [[NSUserDefaults standardUserDefaults] setObject:customer.firstName forKey:@"firstName"];
    //    [[NSUserDefaults standardUserDefaults] setObject:customer.lastName forKey:@"lastName"];
    [[NSUserDefaults standardUserDefaults] setObject:customer.identifier forKey:@"customerId"];
    [[NSUserDefaults standardUserDefaults] setObject:customer.email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:customer.lastName forKey:@"lastName"];
    //    [[NSUserDefaults standardUserDefaults] setObject:customer.defaultAddress.address1 forKey:@"address"];
  
    
    
    
}

-(void)addressAdded{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.isAddAddress) {
        [self.navigationController popViewControllerAnimated:YES];
    } else{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    HomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
    [self.navigationController setViewControllers:@[homeVc]];
    }
}

-(void)registerfailed:(NSNotification*)notification{
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


-(void)addressFailed{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please check you internet connection" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];

}
    
#pragma mark - text field delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.workVC.workAreaTextField) {
        [self.workVC.workAreaTextField resignFirstResponder];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Area" rows:self.areasArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.workVC.workAreaTextField.text = selectedValue;
        } cancelBlock:nil origin:self.workVC.workAreaTextField];
    }
    if (textField == self.homeVC.homeAreaTextField) {
        [self.homeVC.homeAreaTextField resignFirstResponder];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Area" rows:self.areasArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.homeVC.homeAreaTextField.text = selectedValue;
        } cancelBlock:nil origin:self.homeVC.homeAreaTextField];
    }
    
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField{

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    
    CGRect f = self.view.frame;
    f.origin.y = 63.0f;
    self.view.frame = f;
    
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height+100;
        self.view.frame = f;
    }];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.1 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 63.0f;
        self.view.frame = f;
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"workSegue"]) {
        WorkContainerViewController *workVC = [segue destinationViewController];
        self.workVC = workVC;
    } else if ([segue.identifier isEqualToString:@"homeSegue"]){
        HomeContainerViewController *homeVC = [segue destinationViewController];
        self.homeVC = homeVC;
    }
}


@end
